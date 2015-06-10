module FileUtils
  def self.ensure_folder_exists(folder_path)
    unless File.exists? folder_path
      FileUtils::mkdir_p folder_path
    end
  end
end
