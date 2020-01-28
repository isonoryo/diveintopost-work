class OwnerChangeMailer < ApplicationMailer
  default from: 'from@example.com'

  def owner_change_mail(email)
    @email = email
      mail to: @email, subject:"オーナー権限が委譲されました。"
  end
end
