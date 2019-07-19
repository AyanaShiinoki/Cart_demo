require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe "購物車基本功能" do
    it "可以把商品丟進購物車裡，購物車就會有東西了" do
      cart = Cart.new           #新增一台購物車
      cart.add_item 1           #丟一個商品進購物車
      expect(cart.empty?).to be false #它應該不是空的
    end

    it "如果加了相同種類的商品到購物車裡，購買項目(CartItem)並不會增加，但商品數量會改變" do
      cart = Cart.new           #新增一台購物車
      3.times { cart.add_item(1) } 
      5.times { cart.add_item(2) }
      2.times { cart.add_item(3) }
      expect(cart.items.length).to be 3  #總共應該會有3個item
      expect(cart.items.first.quantity).to be 3  #第一個item數量會是3
      expect(cart.items.second.quantity).to be 5  #第一個item數量會是5
    end

    it "商品可以放進購物車裡，也可以再拿出來" do
      cart = Cart.new
      p1 = Product.create(title:"DB")
      p2 = Product.create(title:"NARUTO")
      4.times { cart.add_item(p1.id) }    #放了 4 次的商品 1
      2.times { cart.add_item(p2.id) }    #放了 2 次的商品 2

      expect(cart.items.first.product_id).to be p1.id   #第 1 個 item 的商品 id 應該會等於商品 1 的 id
      expect(cart.items.second.product_id).to be p2.id   #第 2 個 item 的商品 id 應該會等於商品 2 的 id
      expect(cart.items.first.product).to be_a Product   #第 1 個 item 拿出來的東西應該是一種商品
    end

    it "可以計算整台購物車的總消費金額" do
      cart = Cart.new
      p1 = Product.create(title:"DB", price: 80)
      p2 = Product.create(title:"NARUTO", price: 200)

      3.times {
        cart.add_item(p1.id)
        cart.add_item(p2.id)
      }

      expect(cart.total_price).to be 840
    end

    it "特別活動可搭配折扣(例如聖誕節時全面九折，或是滿額滿千送百)" do
    end
  end

  describe "進階功能" do
    it "可將購物車內容轉換成 Hash，存到 Session 裡" do
      cart = Cart.new
      3.times { cart.add_item(2) }
      4.times { cart.add_item(5) }

      expect(cart.serialize).to eq session_hash
    end

    it "可以把 Session 的內容( Hash 格式)，還原成購物車的內容" do
      cart = Cart.from_hash(session_hash)

      expect(cart.items.first.product_id).to be 2
      expect(cart.items.first.quantity).to be 3
      expect(cart.items.second.product_id).to be 5
      expect(cart.items.second.quantity).to be 4
    end
  end

  private
  def session_hash
    {
      "items" => [
        {"product_id" => 2, "quantity" => 3},
        {"product_id" => 5, "quantity" => 4}
      ]
    }
  end
end
