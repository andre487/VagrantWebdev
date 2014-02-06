require 'shellwords'

module Params
  HOME = ENV['HOME']
  CURRENT_DIR = File.dirname(__FILE__)
  PROVISION_DIR = CURRENT_DIR + '/provision'

  def Params.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def Params.get
    ini_values = {}
    File.open(CURRENT_DIR + '/params.ini', 'r') do |paramsFile|
      paramsFile.each_line do |line|
        matches = line.match(/^(.+?)\s*=\s*(.*)$/)
        if matches
          key, val = matches.captures
          ini_values[key] = val
        end
      end
    end

    params = {
        :box => ini_values['box'],
        :box_url => ini_values['box_url'],
        :server_ip => ini_values['server_ip'],
        :memory => ini_values['memory'],
        :use_smtp => ini_values['use_smtp'],
        :smtp_host => ini_values['smtp_host'],
        :smtp_port => ini_values['smtp_port'],
        :smtp_user => ini_values['smtp_user'],
        :smtp_password => ini_values['smtp_password'],
        :smtp_sender => ini_values['smtp_sender'],
        :www_dir => ini_values['www_dir'].sub('~', HOME),
    }
    return params
  end

  def Params.build_args
    arg_names = [:server_ip, :use_smtp, :smtp_host, :smtp_port, :smtp_user, :smtp_password, :smtp_sender]
    params = Params.get.select { |key,| arg_names.include? key }

    args = []
    params.each { |key, val| args.push("--#{key}='#{Shellwords.escape(val)}'") }
    return args.join(' ')
  end
end
