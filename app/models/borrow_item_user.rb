class BorrowItemUser < ApplicationRecord

	include ApplicationHelper

	belongs_to :item
	belongs_to :user
	
	has_many :borrow_item_admin
	has_many :borrow_message
	has_many :borrow_item_follow_up
	has_many :list_borrow_item
	has_many :borrow_item_account

	validates :numbers, length: {minimum: 1}
	validates :count, length: {minimum: 1}
	validates :uuid, uniqueness: true

	before_save {self.is_deleted = false}

	$pers = Array["Hour", "Day", "Week", "Month", "Year"]
	$statuses = Array["accepted", "rendered", "returned", "succeeded"]

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

	def price_to_s
		return number_to_s(self.price)
	end

	def penalties_to_s
		return number_to_s(self.penalties)
	end

	def total_to_s
		return number_to_s(self.price * self.numbers * self.count)
	end

	def borrow_total_to_s
		return number_to_s(self.borrow_total)
	end

	def borrow_total
		return (self.price * self.updated_numbers * self.count) + self.penalties
	end

	def _code
		message = self.borrow_message.where("message = :message", {message: "accepted"}).first
		return (message) ? self.created_at.to_i + message.created_at.to_i - self.updated_at.to_i : Time.new.to_i
	end

	def code
		return self._code + self.id
	end

	def updated_numbers
		received = self.borrow_item_admin.where(status: "received").last
		if $statuses.include?(self.status) and received != nil then
			if self.from_date < received.created_at then
				date = to_datetime(self.to_date) - to_datetime(received.created_at)
				if self.per == $pers[0] and self.numbers > 4 then
					return (self.to_date.localtime - received.created_at.localtime).to_i / (60 * 60 * 1000)
				elsif self.per == $pers[1] then
					return date.to_i / (24 * 60 * 60)
				elsif self.per == $pers[2] then
					return date.to_i / (7 * 24 * 60 * 60)
				elsif self.per == $pers[3] then
					return date.to_i / (30 * 24 * 60 * 60)
				elsif self.per == $pers[4]
					return date.to_i / (12 * 30 * 24 * 60 * 60)
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

	def deadline

		received = self.borrow_item_admin.where(status: "received").last
		rendered = self.borrow_item_admin.where(status: "rendered").last

		if received != nil then
			if rendered == nil then
				if self.per == $pers[0] then
					return (self.numbers < 3) ? check_date(received.created_at.localtime, 0, 0, 30) : check_date(received.created_at.localtime, 0, 1, 0)
				elsif self.per == $pers[1] then
					return (self.numbers < 3) ? check_date(received.created_at.localtime, 0, 12, 0) : check_date(received.created_at.localtime, 1, 0, 0)
				elsif self.per == $pers[2] then
					return check_date(received.created_at.localtime, 2, 0, 0)
				else
					return check_date(received.created_at.localtime, 3, 0, 0)
				end
			end
		else
			return self.to_date
		end
	end

	def penalties

		rendered = self.borrow_item_admin.where(status: "rendered").last
		returned = self.borrow_item_admin.where(status: "returned").last

		now = Time.now
		dead = now.to_time.to_i - self.to_date.localtime.to_time.to_i
		hours = (dead / (60 * 60)) - 4

		if rendered != nil && returned == nil then
			return (hours > 0) ? hours * self.price_per_hour * self.count : 0
		elsif rendered != nil && returned != nil then
			return ((returned.created_at.to_time.to_i - self.to_date.localtime.to_time.to_i) / (60 * 60)) * self.price_per_hour * self.count
		else
			return 0
		end
	end

	def penalties_start_time
		return check_date(self.to_date.localtime, 0, 4, 0)
	end

	def price_per_hour
		case self.per
			when $pers[0] then
				return self.price
			when $pers[1] then
				return self.price / 24
			when $pers[2] then
				return self.price / (7 * 24)
			when $pers[3] then
				return self.price / (30 * 24)
			when $pers[4] then
				return self.price / (12 * 30 * 24)
			else
				return 0
		end
	end

	private def to_datetime(date)
        return Time.local(date.year, date.month, date.day, 0, 0, 0)
    end

    private def check_date(date, days, hours, minutes)
    	return date + (days.to_i * 24 * 60 * 60) + (hours.to_i * 60 * 60) + (minutes.to_i * 60)
    end
end
