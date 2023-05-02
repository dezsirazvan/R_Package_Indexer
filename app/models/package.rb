class Package < ApplicationRecord
  validates_presence_of :name, :versions
end