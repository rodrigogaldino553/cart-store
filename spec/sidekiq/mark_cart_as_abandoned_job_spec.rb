require "rails_helper"
RSpec.describe MarkCartAsAbandonedJob, type: :job do
  context "#perform" do
    it "marks carts as abandoned after 3 hours" do
      cart = create(:cart, last_interaction_at: 4.hours.ago)

      MarkCartAsAbandonedJob.new.perform

      expect(cart.reload.status).to eq("abandoned")
      expect(cart.abandoned_at).to be_present
    end

    it "does not mark recent carts as abandoned" do
      cart = create(:cart, last_interaction_at: 2.hours.ago)

      MarkCartAsAbandonedJob.new.perform

      expect(cart.reload.status).to eq("active")
    end

    it "deletes abandoned carts after 7 days" do
      create(:cart, :abandoned, abandoned_at: 8.days.ago)

      expect {
        MarkCartAsAbandonedJob.new.perform
      }.to change(Cart, :count).by(-1)
    end

    it "does not delete recently abandoned carts" do
      create(:cart, :abandoned, abandoned_at: 5.days.ago)

      expect {
        MarkCartAsAbandonedJob.new.perform
      }.not_to change(Cart, :count)
    end
  end
end
