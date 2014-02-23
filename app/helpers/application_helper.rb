module ApplicationHelper
  def btc_human amount, options = {}
    return nil unless amount
    nobr = options.has_key?(:nobr) ? options[:nobr] : true
    currency = options[:currency] || false
    btc = "%.8f PPC" % to_btc(amount)
    btc = "<span class='convert-from-btc' data-to='#{currency.upcase}'>#{btc}</span>" if currency
    btc = "<nobr>#{btc}</nobr>" if nobr
    btc.html_safe
  end

  def to_btc satoshies
    satoshies.to_d / PeercoinBalanceUpdater::COIN if satoshies
  end

  def transaction_url(txid)
    "http://bkchain.org/ppc/tx/#{txid}"
  end

  def render_flash_message
    html = []
    flash.each do |_type, _message|
      alert_type = case _type
        when :notice then :success
        when :alert  then :danger
      end
      html << content_tag(:div, class: "text-center alert alert-#{alert_type}"){ _message }
    end
    html.join("\n").html_safe
  end
end
