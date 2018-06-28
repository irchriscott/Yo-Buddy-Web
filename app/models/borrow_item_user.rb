class BorrowItemUser < ApplicationRecord

	belongs_to :item
	belongs_to :user
	has_many :borrow_item_admin
	has_many :borrow_message
	has_many :borrow_item_follow_up
	has_many :list_borrow_item

	validates :numbers, length: {minimum: 1}
	validates :count, length: {minimum: 1}
	validates :uuid, uniqueness: true

	before_save {self.is_deleted = false}

	def check_expiration

		from = self.from_date.localtime
		to = self.to_date.localtime
		
		now = Time.now

		if self.status == "pending" or self.status == "rejected" then
			if now > from and now < to then
				return "orange"
			else
				return "lightgreen"
			end	
		elsif self.status == "failed" then
			return "red"
		else
			return "green"
		end
	end

	def borrow_total
		return self.price * self.updated_numbers * self.count
	end

	def _code
		message = BorrowMessage.where("borrow_item_user_id = :id AND message = :message", {id: self.id, message: "accepted"}).first
		if message then
			return self.created_at.to_i + message.created_at.to_i - self.updated_at.to_i
		else
			return Time.new.to_i
		end
	end

	def code
		return self._code + self.id
	end

	def updated_numbers
		statuses = Array["accepted", "rendered", "returned", "succeeded"]
		received = self.borrow_item_admin.where(status: "received").last
		pers = Array["Hour", "Day", "Week", "Month", "Year"]
		if statuses.include?(self.status) and received != nil then
			if self.from_date < received.created_at then
				date = to_datetime(self.to_date) - to_datetime(received.created_at)
				if self.per == pers[0] and self.numbers > 4 then
					return (self.to_date.localtime - received.created_at.localtime).to_i / (60 * 60 * 1000)
				elsif self.per == pers[1] then
					return date.to_i / (24 * 60 * 60 * 1000)
				elsif self.per == pers[2] then
					return date.to_i / (7 * 24 * 60 * 60 * 1000)
				elsif self.per == pers[3] then
					return date.to_i / (30 * 24 * 60 * 60 * 1000)
				elsif self.per == pers[4]
					return date.to_i / (12 * 30 * 24 * 60 * 60 * 1000)
				else
					return self.numbers 
				end	
			else
				return self.numbers
			end
		else
			return self.numbers
		end
	end

	private def to_datetime(date)
        return Time.local(date.year, date.month, date.day, 0, 0, 0)
    end
end
