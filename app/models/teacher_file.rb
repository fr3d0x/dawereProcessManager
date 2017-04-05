class TeacherFile < ActiveRecord::Base
  belongs_to :vdm
  mount_base64_uploader :file, TeacherFilesUploader
end
