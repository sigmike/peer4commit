module ApplicationHelper
  def btc_human amount, options = {}
    return nil unless amount
    options = (@default_btc_human_options || {}).merge(options)
    nobr = options.has_key?(:nobr) ? options[:nobr] : true
    currency = options[:currency] || false
    precision = options[:precision] || 2
    display_currency = options.fetch(:display_currency, true)
    btc = "%.#{precision}f" % to_btc(amount)
    btc += " PPC" if display_currency
    btc = "<span class='convert-from-btc' data-to='#{currency.upcase}'>#{btc}</span>" if currency
    btc = "<nobr>#{btc}</nobr>" if nobr
    btc.html_safe
  end

  def with_btc_human_defaults(defaults)
    @old_btc_human_defaults ||= []
    @old_btc_human_defaults << @default_btc_human_options
    @default_btc_human_options = defaults.dup
    yield
    @default_btc_human_options = @old_btc_human_defaults.pop
  end

  def to_btc satoshies
    satoshies.to_d / COIN if satoshies
  end

  def transaction_url(txid)
    "https://chainz.cryptoid.info/ppc/tx.dws?#{txid}"
  end

  def address_explorers
    [:cryptoid, :blockr, :mintr]
  end

  def address_url(address, explorer = address_explorers.first)
    case explorer
    when :blockr then "https://ppc.blockr.io/address/info/#{address}"
    when :cryptoid then "https://chainz.cryptoid.info/ppc/address.dws?#{address}"
    when :mintr then "https://peercoin.mintr.org/address/#{address}"
    else raise "Unknown provider: #{provider.inspect}"
    end
  end

  def truncate_commit(sha1)
    truncate(sha1, length: 10, omission: "")
  end

  def commit_tag(sha1)
    content_tag(:span, truncate_commit(sha1), class: "commit-sha")
  end

  def render_flash_message
    html = []
    flash.each do |type, message|
      alert_type = case type
        when :notice then :success
        when :alert, :error then :danger
        else type
      end
      html << content_tag(:div, message, class: "flash-message text-center alert alert-#{alert_type}")
    end
    html.join("\n").html_safe
  end

  def render_markdown(source)
    return nil unless source

    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(safe_links_only: true, filter_html: true), autolink: true)
    html = markdown.render(source)
    clean = Sanitize.clean(html, Sanitize::Config::RELAXED)
    clean.html_safe
  end
end
