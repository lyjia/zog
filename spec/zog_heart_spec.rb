require 'spec_helper'


describe "Zog::Heart, the heart of Zog," do

  context 'with default config,' do

    subject {Zog}

    it 'logs to its default output of STDERR' do
      expect {subject.info("Zog test message")}.to output.to_stderr_from_any_process #why wont this work with just #to_stderr?
    end

  end

  context 'with universal custom config option:' do

    context ':stream_colorize' do

      context 'disabled' do
        subject {Zog.new(stream_colorize: false)}
        it 'logs correctly' do
          expect {subject.info("Zog test message")}.to_not output(/#{Zog::Constants::BASH_COLOR_NORMAL.gsub("[", '\[')}/).to_stderr_from_any_process
        end
      end

      context 'enabled' do
        subject {Zog.new(stream_colorize: true)}
        it 'logs correctly' do
          expect {subject.info("Zog test message")}.to output(/#{Zog::Constants::BASH_COLOR_NORMAL.gsub("[", '\[')}/).to_stderr_from_any_process
        end
      end

    end

    context ':format_output' do

      context 'with non-temporal tokens' do
        subject {Zog.new(format_output: [:severity, ' - ', :message])}
        it 'logs correctly' do
          expect {subject.info("test")}.to output("info - test").to_stderr_from_any_process
        end
      end

      context 'with temporal tokens' do
        before do
          Timecop.freeze(Time.local("2019-01-01 12:00:00"))
        end

        after do
          Timecop.return
        end

        subject {Zog.new(stream_colorize: false)}

        it 'logs correctly' do
          expect {subject.info("test")}.to output(/20190101/).to_stderr_from_any_process
        end

      end

    end

    context ':format_date' do
      before do
        Timecop.freeze(Time.local("2019-01-01 12:00:00"))
      end

      after do
        Timecop.return
      end

      context "with custom date string" do
        subject {Zog.new(stream_colorize: false, format_date: "%Y-%m-%d")}
        it 'logs correctly' do
          expect {subject.info("test")}.to output(/2019-01-01/).to_stderr_from_any_process
        end
      end
    end

    context ':allowed_categories' do
      subject {Zog.new(allowed_categories: :error)}
      it 'doesnt log disallowed categories' do
        expect {subject.debug("test")}.to_not output.to_stderr_from_any_process
      end

      it 'does log allowed categories' do
        expect {subject.info("test")}.to output.to_stderr_from_any_process
      end
    end

  end
end