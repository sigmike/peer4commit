module ApplicationHelper
  def ppc_human amount, options = {}
    nobr = options.has_key?(:nobr) ? options[:nobr] : true
    ppc = "%.8f PPC" % to_ppc(amount)
    ppc = "<nobr>#{ppc}</nobr>" if nobr
    ppc.html_safe
  end

  def to_ppc satoshies
    (1.0*satoshies.to_i/1e8)
  end
end
