module Api
  module V1
    class CartsController < ApplicationController
      before_action :set_cart, only: %i[create update show destroy]

      def show
        return render json: {errors: ["Cart not found"]}, status: :not_found if @cart.nil?

        render_cart(@cart)
      end

      def create
        new_cart if @cart.nil?
        product = Product.find(params[:product_id])
        cart_item = @cart.cart_items.find_or_initialize_by(product_id: product.id)
        cart_item.quantity += params.fetch(:quantity, 1).to_i

        if cart_item.save
          render_cart(@cart)
        else
          render json: {errors: cart_item.errors.full_messages}, status: :unprocessable_entity
        end
      end

      def update
        cart_item = @cart.cart_items.find_by(product_id: cart_params[:product_id])
        if cart_item
          cart_item.quantity += params.fetch(:quantity, 0).to_i
          if cart_item.save
            render_cart(@cart)
          else
            render json: {errors: cart_item.errors.full_messages}, status: :unprocessable_entity
          end
        else
          render json: {errors: ["Product not found in your cart"]}, status: :not_found
        end
      end

      def destroy
        return render json: {errors: ["Your cart is empty"]}, status: :not_found unless @cart.cart_items.exists?

        cart_item = @cart.cart_items.find_by(product_id: params[:product_id])
        if cart_item
          cart_item.destroy
          return render_cart(@cart) unless @cart.cart_items.empty?

          render json: {message: "Product removed, now your cart is empty"}, status: :ok
        else
          render json: {errors: ["The product was not found in your cart"]}, status: :not_found
        end
      end

      private

      def set_cart
        @cart = Cart.find_by(id: session[:cart_id])
      end

      def new_cart
        @cart = Cart.create(total_price: 0)
        session[:cart_id] = @cart.id
      end

      def render_cart(cart)
        render json: {
          id: cart.id,
          products: cart.cart_items.map do |item|
            {
              id: item.product.id,
              name: item.product.name,
              quantity: item.quantity,
              unit_price: item.product.price,
              total_price: item.product.price * item.quantity
            }
          end,
          total_price: cart.total_price
        }
      end
    end
  end
end
