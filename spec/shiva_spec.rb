# required by Shiva::Database
require 'active_support/inflector'

describe Shiva do
  describe :configuration do
    it 'raises error without configuration' do
      lambda {
        Shiva.configuration
      }.should raise_exception
    end

    context 'with configuration set' do
      before do
        Shiva.configure do
          database 'fake'
        end
      end

      its(:configuration) { should be_a(Shiva::Configurator)}
      # don't use
      # its(:configuration) { should_not raise_exception }
      # it tries to .call on Configurator. There's nothing to call!
      it 'does not raise' do
        lambda {
          Shiva.configuration
        }.should_not raise_exception
      end
    end
  end
end
