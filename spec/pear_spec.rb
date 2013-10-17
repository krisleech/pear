require 'spec_helper'

require 'securerandom'
require 'virtus'
require 'rom'
require 'axiom-memory-adapter'

describe Pear do
  it 'works' do

    env = ROM::Environment.setup(memory: 'memory://test')

    env.schema do
      base_relation :projects do
        repository :memory

        attribute :id,   Integer
        attribute :name, String

        key :id
      end
    end

    # domain object
    class Project
      include Virtus

      attribute :id, Integer, :default => SecureRandom.uuid
      attribute :name, String
    end

    # mapper
    env.mapping do
      projects do
        map :id, :name
        model Project
      end
    end

    # persist to data store
    env.session do |session|
      project = session[:projects].new(name: 'Rule the world')
      session[:projects].save(project)
      session.flush
    end

    # fetch from data store
    project = env[:projects].restrict(name: 'Rule the world').one

    project.class.should == Project

    puts project.inspect

  end
end
