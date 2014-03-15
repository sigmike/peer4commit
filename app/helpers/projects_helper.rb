module ProjectsHelper

  def shield_btc_amount amount
    btc_amount = to_btc amount
    "%.#{6 - btc_amount.to_i.to_s.length}f PPC" % btc_amount
  end

  def shield_color project
    last_tip = project.tips.order(:created_at).last
    if last_tip.nil? || (Time.current - last_tip.created_at > 30.days)
      'red'
    elsif (Time.current - last_tip.created_at > 7.days)
      'yellow'
    elsif (Time.current - last_tip.created_at > 1.day)
      'yellowgreen'
    else
      'green'
    end
  end
end
