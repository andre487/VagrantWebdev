module Params
  CURRENT_DIR = File.dirname(__FILE__)
  PROVISION_DIR = CURRENT_DIR + '/provision'

  def Params.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def Params.get
    ini_values = {}
    File.open(CURRENT_DIR + '/params.ini', 'r') do |paramsFile|
      paramsFile.each_line do |line|
        matches = line.match(/^(.+?)\s*=\s*(.+)$/)
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
    }
    if windows?
      params[:www_dir] = ini_values['www_dir.win32']
    else
      params[:www_dir] = ini_values['www_dir.unix']
    end

    return params
  end
end
