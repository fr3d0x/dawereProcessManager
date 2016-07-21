class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :firstName
      t.string :middleName
      t.string :firstSurname
      t.string :secondSurname
      t.float :currentSalary
      t.date :birthDate
      t.string :personalId
      t.string :rif
      t.string :jobTittle
      t.date :admissionDate
      t.string :phone
      t.string :cellphone
      t.text :address
      t.string :email
      t.string :email2

      t.timestamps null: false
    end
  end
end
