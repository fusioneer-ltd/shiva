describe Shiva::Configurator do

  subject { Shiva::Configurator.new }

  its(:_databases) { should be_empty }
  context 'database and _databases' do
    it 'raises on no arguments' do
      lambda {
        subject.database
      }.should raise_exception ArgumentError, /You have to specify database name/
    end

    it 'prompts on passing a class' do
      lambda {
        subject.database(Integer)
      }.should raise_exception ArgumentError, /preloading issues/
    end

    it 'raises on non-string arguments' do
      lambda {
        subject.database(42)
      }.should raise_exception ArgumentError, /Only strings are allowed/
    end

    it 'saves databases in config' do
      subject.database('FakeDatabase')
      subject._databases.first.should be_a(Shiva::Database)
    end

    it 'saves database model with a different database name' do
      subject.database('FakeDatabase', 'fake_database_name')
      subject.should_not_receive :friendly_name_for_base_model
      subject._databases.first.should be_a(Shiva::Database)
    end
  end

  context 'friendly_name_for_base_model' do
    {'FakeDatabase' => 'fake_database', 'Databases::FakeOne' => 'fake_one', 'Something' => 'something'}.each do |class_name, base_model_name|
      it "converts #{class_name} to #{base_model_name}" do
        subject.send(:friendly_name_for_base_model, class_name).should eq base_model_name
      end
    end
  end
end
