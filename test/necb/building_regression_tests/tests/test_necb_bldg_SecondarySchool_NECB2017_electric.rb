require_relative '../../../helpers/minitest_helper'
require_relative '../../../helpers/create_doe_prototype_helper'
require_relative '../../../helpers/compare_models_helper'
require_relative '../resources/regression_helper'

class Test_SecondarySchool_NECB2017_electric < NECBRegressionHelper
  def setup()
    super()
  end
  def test_NECB2017_SecondarySchool_regression_electric()
    result, diff = create_model_and_regression_test(building_type: 'SecondarySchool',epw_file: @electric_location,template: 'NECB2017')
    if result == false
      puts "JSON terse listing of diff-errors."
      puts diff
      puts "Pretty listing of diff-errors for readability."
      puts JSON.pretty_generate( diff )
      puts "You can find the saved json diff file here test/necb/regression_models/SecondarySchool-NECB2017-#\{@electric_location\%>.epw_diffs.json"
      puts "outputing errors here. "
      puts diff["diffs-errors"] if result == false
    end
    assert(result, diff)
  end
end