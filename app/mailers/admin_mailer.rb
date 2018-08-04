class AdminMailer < ApplicationMailer

  	def register_admin_user(email, password, key)
        @email = email
  		  @password = password
  		  @key = key
    	 mail(to: email, subject: '[Yo Buddy] - Admin User Credintials')
  	end

  	def new_key_sold(user, key)
  		  @key = key
        attachments['yb_admin_user_key.pdf'] = WickedPdf.new.pdf_from_string(
            get_pdf_string(key, user),
            orientation:'Landscape',
            footer: {
                content: "<p>All Rights Reserved ©#{Time.new.year} Yo Buddy</p>"
            },
        )
  		  mail(to: user.email, subject: '[Yo Buddy] - New Key Generated')
  	end

    private def get_pdf_string(key, user)
        return "
            <div style='padding: 50px; margin-top: 150px; color: #333; font-family:Avenir, Century Gothic, sans-serif; position:relative;'>
                <div style='width:100%; padding-bottom: 30px; border-bottom: 4px solid #333;'>
                    <h2 style='text-align:center; font-size: 32px;'>Yo Buddy</h2>
                </div>
                <div style='text-align: center; margin:20px 0;'>
                    <p style='font-size: 22px;'>Yo Buddy - Admin User Key</p>
                    <h1 style='font-size: 45px; margin: 30px 0; display: block; padding: 15px 0; background: #cc8400; color: #fff; text-align: center; border-radius: 8px;'>#{key.get_key}</h1>
                    <p style='font-size: 26px'><strong>Package : </strong>#{key.yb_package.package.capitalize!} Package</p>
                    <p style='font-size: 26px'><strong>Duration : </strong>#{key.duration.to_s} Days</p>
                    <p style='font-size: 26px'><strong>Delivered To : </strong>#{user.user.name}</p>
                    <p style='font-size: 26px'><strong>Date : </strong>#{key.created_at.localtime.strftime("%d %B %Y at %H:%M")}</p>
                </div>
            </div>
        "
    end
end
