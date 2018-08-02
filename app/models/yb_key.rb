class YbKey < ApplicationRecord

	belongs_to :yb_package
	has_many :yb_key_usage
	validates :key, uniqueness: true

	def get_key
  		
		self.key.insert(6, "-")
		self.key.insert(13, "-")
		self.key.insert(20, "-")

		return self.key
  	end
end
