module Unparser
  class Emitter

    # Emitter for rescue nodes
    class Rescue < self

      handle :rescue

      children :body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        k_begin
        indented { visit(body) }
        children[1..-2].each do |child|
          visit(child)
        end
        k_end
      end
    end # Rescue

    # Emitter for enusre nodes
    class Ensure < self

      handle :ensure

      children :body, :ensure_body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        k_begin
        emit_body
        write(K_ENSURE)
        emit_ensure_body
        k_end
      end

      # Emit body
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_body
        indented { visit(body) }
      end

      # Emit ensure body
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_ensure_body
        indented { visit(ensure_body) }
      end

    end # Ensure

    # Emitter for rescue body nodes
    class Resbody < self

      handle :resbody

      children :exception, :assignment, :body

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        write(K_RESCUE)
        emit_exception
        emit_assignment
        if body
          indented { visit(body) }
        else
          nl
        end
      end

      # Emit exception
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_exception
        return unless exception
        ws
        delimited(exception.children)
      end

      # Emit assignment
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_assignment
        return unless assignment
        write(WS, T_ASR, WS)
        visit(assignment)
      end

    end # Resbody

    # Emitter for begin nodes
    class Begin < self

      handle :begin, :kwbegin

    private

      # Perform dispatch
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        if children.length == 1 and !parent.needs_begin?
          visit(first_child)
        else
          emit_normal
        end
      end

      # Emit normal begin block
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_normal
        if parent.needs_begin?
          k_begin
          indented { emit_inner }
          k_end
        else
          emit_inner
        end
      end

      # Emit inner nodes
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_inner
        childs = children
        max = childs.length - 1
        childs.each_with_index do |child, index|
          visit(child)
          nl if index < max
        end
      end

    end # Body
  end # Emitter
end # Unparser
