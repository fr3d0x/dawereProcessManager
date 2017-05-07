class TeacherFile < ActiveRecord::Base
  belongs_to :vdm
  mount_uploader :file, TeacherFilesUploader
end
