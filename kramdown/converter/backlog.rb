module Kramdown
  module Converter
    class Backlog < Base
      # The amount of indentation used when nesting HTML tags.
      attr_accessor :indent

      # Initialize the HTML converter with the given Kramdown document +doc+.
      def initialize(root, options)
        super
        @footnote_counter = @footnote_start = @options[:footnote_nr]
        @footnotes = []
        @toc = []
        @toc_code = nil
        @indent = 2
        @stack = []
      end
      
      # The mapping of element type to conversion method.
      DISPATCHER = Hash.new {|h,k| h[k] = "convert_#{k}"}

      # Dispatch the conversion of the element +el+ to a +convert_TYPE+ method using the +type+ of
      # the element.
      def convert(el, indent = -@indent)
        send(DISPATCHER[el.type], el, indent)
      end

      def inner(el, indent)
        result = ''
        indent += @indent
        @stack.push(el)
        el.children.each do |inner_el|
          result << send(DISPATCHER[inner_el.type], inner_el, indent)
        end
        @stack.pop
        result
      end

      def convert_html_element(el, indent)
        res = inner(el, indent)
        if el.options[:category] == :span
          "<#{el.value}" << (!res.empty? || HTML_TAGS_WITH_BODY.include?(el.value) ? ">#{res}</#{el.value}>" : " />")
        else
          output = ''
          output << ' '*indent if @stack.last.type != :html_element || @stack.last.options[:content_model] != :raw
          output << "<#{el.value}"
          if !res.empty? && el.options[:content_model] != :block
            output << ">#{res}</#{el.value}>"
          elsif !res.empty?
            output << ">\n#{res.chomp}\n"  << ' '*indent << "</#{el.value}>"
          elsif HTML_TAGS_WITH_BODY.include?(el.value)
            output << "></#{el.value}>"
          else
            output << " />"
          end
          output << "\n" if @stack.last.type != :html_element || @stack.last.options[:content_model] != :raw
          output
        end
      end
      
      def convert_p(el, indent)
        if el.options[:transparent]
          inner(el, indent)
        else
          "&br;\n#{inner(el, indent)}"
        end
      end
            
      def convert_text(el, indent)
        el.value
      end
  
      def convert_blank(el, indent)
        "\n"
      end
      
      def convert_codeblock(el, indent)
          "{code}\n#{el.value}{/code}\n"
      end

      def convert_em(el, indent)
        "''#{inner(el, indent)}''\n"
      end
      alias :convert_strong :convert_em
    
      def convert_header(el, indent)
        attr = el.attr.dup
        "#{'*'*el.options[:level]}#{inner(el, indent)}\n"
      end
      
      def convert_ul(el, indent)
        "#{inner(el, indent)}\n"
      end
      alias :convert_ol :convert_ul
      alias :convert_dl :convert_ul
          
      def convert_li(el, indent)
        output = '-'
        res = inner(el, indent)
        if el.children.empty? || (el.children.first.type == :p && el.children.first.options[:transparent])
          output << res << (res =~ /\n\Z/ ? ' '*indent : '')
        else
          output << "\n" << res << ' '*indent
        end
        output << "\n"
      end
      alias :convert_dd :convert_li

      def convert_table(el, indent)
        inner(el, indent)
      end

      def convert_thead(el, indent)
        "#{inner(el, indent)}"
      end
      
      def convert_tr(el, indent)
        "#{inner(el, indent)}|\n"
      end
      
      alias :convert_tbody :convert_thead
      alias :convert_tfoot :convert_thead

      ENTITY_NBSP = ::Kramdown::Utils::Entities.entity('nbsp') # :nodoc:

      def convert_td(el, indent)
        res = inner(el, indent)
        "|#{res.empty? ? entity_to_str(ENTITY_NBSP) : res}"
      end
                       
      def convert_root(el, indent)
        inner(el, indent)
      end
    end
  end
end