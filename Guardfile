interactor :off

guard :rspec, cmd: "bundle exec rspec", all_after_pass: true, all_on_start: true do
  watch(%r{^lib\/podcast_feed_gen\/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')       { "spec" }
  watch(%r{^spec\/.+_spec\.rb$})
end
