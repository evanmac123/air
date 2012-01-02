# For some reason, we can't convince CopycopterClient that test and cucumber
# are, in fact, test environments, even though that should be the default. So
# we keep it in a group in the Gemfile that prevents test and cucumber from
# ever loading it, hence the const_defined? below.

if Kernel.const_defined?(:CopycopterClient)
  CopycopterClient.configure do |config|
    config.api_key = '876131385e55f4afd3499c4e113fbb85'
  end
end
