module RngHelper
  def rig_rng(klass, expected_limit, values_to_return)
    klass.any_instance.stubs(:rand).with(expected_limit).returns(*values_to_return)
  end
end
