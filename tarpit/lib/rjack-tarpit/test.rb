#--
# Copyright (c) 2009-2011 David Kellum
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You may
# obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#++

module RJack::TarPit

  module TestTaskDefiner

    # Proc for setting Rake TestTask options
    # (default: nil, no-op)
    attr_accessor :test_task_config

    # Support same options as Rake::TestTask, plus tarpit's own
    # :mini_in_proc (default) option, which loads minitest tests and
    # runs in (rake) process.
    attr_accessor :test_loader

    def initialize
      super

      @test_loader = :mini_in_proc
      @test_task_config = nil

      add_define_hook( :define_test_tasks )
    end

    def define_test_tasks

      #FIXME: Add spec support like Hoe

      if test_loader == :mini_in_proc

        tfiles = FileList[ "test/test*.rb" ]
        if !tfiles.empty?

          desc "Run minitest tests (in rake process)"
          task :test do |t,args|
            require 'minitest/unit'

            MiniTest::Unit.class_eval do
              def self.autorun
                # disable autorun, as we are running ourselves
              end
            end

            tfiles.each { |f| load f }

            code = MiniTest::Unit.new.run( ( ENV['TESTOPTS'] || '' ).split )
            fail "test failed (#{code})" if code && code > 0
            puts
          end

        else
          desc "No-op"
          task :test
        end

      else

        require 'rake/testtask'

        Rake::TestTask.new do |t|
          t.loader = test_loader
          test_task_config.call( t ) if test_task_config
        end

      end

      #FIXME: Make this conditional with above test (avoid empty?)
      task :default => [ :test ]

    end

  end

end
