require 'yaml'
require 'i18n'
require 'open-uri'
require 'webdrivers'

module EsuppDownloadNotify
  CONFIG = YAML.load_file('./config/config.yml').transform_keys(&:to_sym).freeze
  I18n.load_path << Dir["#{File.expand_path('./config/locales')}/*.yml"]
  I18n.default_locale = CONFIG[:locale].to_sym

  class << self
    def run
      driver = create_driver

      login(driver)
      records = download(driver)

      text_to_notify = create_text_to_notify(records)
      if use_slack_notification?(text_to_notify)
        slack_notification(text_to_notify)
      else
        puts text_to_notify
      end

      driver.quit
    end

    private

    def slack_notification(text_to_notify)
      uri = URI.parse(CONFIG[:slack_webhook])
      Net::HTTP.post_form(uri, { payload: { text: text_to_notify }.to_json })
    end

    def create_text_to_notify(records)
      system_data = load_system_data
      data = parse_records(records)
      if data_equal?(system_data, data)
        nil
      else
        save_system_data(data)
        I18n.t(
          'text_to_notify', content1: data[:content1], created_date1: data[:created_date1],
                            content2: data[:content2], created_date2: data[:created_date2],
                            content3: data[:content3], created_date3: data[:created_date3],
                            content4: data[:content4], created_date4: data[:created_date4],
                            content5: data[:content5], created_date5: data[:created_date5]
        )
      end
    end

    def parse_records(records)
      records.each_with_index.with_object({}) do |(tr, i), result|
        # INDEX=0はヘッダ行の為無視
        next if i.zero?
        # 上位5件だけ取得
        break result if i > 5

        td = tr.find_elements(tag_name: 'td')

        result["content#{i}".to_sym] = td[1].text.strip
        result["created_date#{i}".to_sym] = td[2].text.strip
      end
    end

    def use_slack_notification?(text_to_notify)
      !CONFIG[:slack_webhook].nil? && !text_to_notify.nil?
    end

    def data_equal?(data1, data2)
      return false if CONFIG[:test]

      data1 == data2
    end

    def create_driver
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless') if CONFIG[:headless]
      driver = Selenium::WebDriver.for(:chrome, options: options)
      driver.manage.timeouts.implicit_wait = 500
      driver
    end

    def login(driver)
      driver.get(CONFIG[:login_url])

      username1 = driver.find_element(name: 'Username1')
      password1 = driver.find_element(name: 'Password1')
      submit_button = driver.find_element(css: 'input[type="button"]')

      username1.send_keys(CONFIG[:username])
      password1.send_keys(CONFIG[:password])
      submit_button.click

      driver.switch_to.alert.accept
    end

    def download(driver)
      driver.get(CONFIG[:download_url])

      tables = driver.find_elements(tag_name: 'table')
      tables[5].find_elements(tag_name: 'tr')
    end

    SYSTEM_DATA_PATH = './config/system_data.yml'.freeze
    def load_system_data
      File.open(SYSTEM_DATA_PATH, 'w') unless File.exist?(SYSTEM_DATA_PATH)
      File.open(SYSTEM_DATA_PATH, 'r') { |f| YAML.safe_load(f) }&.transform_keys(&:to_sym)
    end

    def save_system_data(data)
      YAML.dump(data.transform_keys(&:to_s), File.open(SYSTEM_DATA_PATH, 'w'))
    end
  end
end
