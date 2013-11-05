require "spec_helper"
require "drunkmonkey"

module DrunkMonkey
  describe Controller do
    describe "#initialize" do
      specify do
        expect(Celluloid::Actor[:test_controller]).to be_nil
        controller = Controller.new :test_controller
        expect(controller).to eq(Celluloid::Actor[:test_controller])
        expect(controller.instance_variable_get(:@handlers)).to eq(Hash.new)
      end
    end
    
    describe "#on" do
      specify do
        controller = Controller.new :test_controller
        handler = proc do |socket, message|
        end
        controller.on :message, &handler
        expect(controller.instance_variable_get(:@handlers)).to eq({message: handler})
      end
    end
    
    describe "#fire" do
      specify do
        controller = Controller.new :test_controller
        controller.on :message do |socket, message|
          raise StandardError, [socket, message].to_s
        end
        expect{controller.fire :message, 1, 2}.to raise_error([1,2].to_s)
      end
    end
  end
end