class Standard
  # @!group Sizing System

  # Prototype SizingSystem object
  #
  # @param air_loop_hvac [<OpenStudio::Model::AirLoopHVAC>] air loop to set sizing system properties
  # @param dsgn_temps [Hash] a hash of design temperature lookups from standard_design_sizing_temperatures
  def adjust_sizing_system(air_loop_hvac,
                           dsgn_temps,
                           type_of_load_sizing: 'Sensible',
                           min_sys_airflow_ratio: 0.3,
                           sizing_option: 'Coincident')

    # adjust sizing system defaults
    sizing_system = air_loop_hvac.sizingSystem
    sizing_system.setTypeofLoadtoSizeOn(type_of_load_sizing)
    sizing_system.autosizeDesignOutdoorAirFlowRate
    sizing_system.setPreheatDesignTemperature(dsgn_temps['prehtg_dsgn_sup_air_temp_c'])
    sizing_system.setPrecoolDesignTemperature(dsgn_temps['preclg_dsgn_sup_air_temp_c'])
    sizing_system.setCentralCoolingDesignSupplyAirTemperature(dsgn_temps['clg_dsgn_sup_air_temp_c'])
    sizing_system.setCentralHeatingDesignSupplyAirTemperature(dsgn_temps['htg_dsgn_sup_air_temp_c'])
    sizing_system.setPreheatDesignHumidityRatio(0.008)
    sizing_system.setPrecoolDesignHumidityRatio(0.008)
    sizing_system.setCentralCoolingDesignSupplyAirHumidityRatio(0.0085)
    sizing_system.setCentralHeatingDesignSupplyAirHumidityRatio(0.0080)
    sizing_system.setMinimumSystemAirFlowRatio(min_sys_airflow_ratio)
    sizing_system.setSizingOption(sizing_option)
    sizing_system.setAllOutdoorAirinCooling(false)
    sizing_system.setAllOutdoorAirinHeating(false)
    sizing_system.setSystemOutdoorAirMethod('ZoneSum')
    sizing_system.setCoolingDesignAirFlowMethod('DesignDay')
    sizing_system.setHeatingDesignAirFlowMethod('DesignDay')

    return sizing_system
  end

  def model_system_outdoor_air_sizing_vrp_method(air_loop_hvac)
    sizing_system = air_loop_hvac.sizingSystem
    # Only apply to prototypes maintained by PNNL
    if template.include? ("90.1") and (@instvarbuilding_type == 'HighriseApartment' or
      @instvarbuilding_type == 'Warehouse' or 
      @instvarbuilding_type == 'SecondarySchool' or
      @instvarbuilding_type == 'LargeHotel' or 
      @instvarbuilding_type == 'Outpatient' or
      @instvarbuilding_type == 'MidriseApartment' or
      @instvarbuilding_type == 'PrimarySchool' or
      @instvarbuilding_type == 'SmallHotel' or
      @instvarbuilding_type == 'MediumOffice' or
      @instvarbuilding_type == 'SmallOffice' or
      @instvarbuilding_type == 'RetailStandalone' or
      @instvarbuilding_type == 'Hospital' or
      @instvarbuilding_type == 'LargeOffice' or
      @instvarbuilding_type == 'FullServiceRestaurant' or
      @instvarbuilding_type == 'RetailStripmall' or
      @instvarbuilding_type == 'QuickServiceRestaurant')
      sizing_system.setSystemOutdoorAirMethod("VentilationRateProcedure")
      # Set the minimum zone ventilation efficiency to be 0.6
      air_loop_hvac.thermalZones.sort.each do |zone|
        sizing_zone = zone.sizingZone
        sizing_zone.setDesignZoneAirDistributionEffectivenessinCoolingMode(0.6)
        sizing_zone.setDesignZoneAirDistributionEffectivenessinHeatingMode(0.6)
      end
    end

    return true  
  end
end