# This abstract class holds generic methods that many energy standards would commonly use.
# Many of the methods in this class apply efficiency values from the
# OpenStudio-Standards spreadsheet.  If a method in this class is redefined
# by a subclass, the implementation in the subclass is used.
# @abstract
class Standard
  attr_reader :standards_data
  attr_reader :template

  # The code below is required for the factory method. For an explanation see
  # https://stackoverflow.com/questions/1515577/factory-methods-in-ruby and clakes post. Which I think is the cleanest
  # implementation.
  # This creates a constant HASH to be set  during class instantiation.
  # When adding standards you must register the class by invoking 'register_standard ('NECB2011')' for example for
  # NECB2011.

  # A list of available Standards subclasses that can
  # be created using the Standard.build() method.
  STANDARDS_LIST = {} # rubocop:disable Style/MutableConstant

  # Add the standard to the STANDARDS_LIST.
  def self.register_standard(name)
    STANDARDS_LIST[name] = self
  end

  # Create an instance of a Standard by passing it's name
  #
  # @param name [String] the name of the Standard to build.
  #   valid choices are: DOE Pre-1980, DOE 1980-2004, 90.1-2004,
  #   90.1-2007, 90.1-2010, 90.1-2013, NREL ZNE Ready 2017, NECB2011
  # @example Create a new Standard object by name
  #   standard = Standard.build('NECB2011')
  def self.build(name)
    if STANDARDS_LIST[name].nil?
      raise "ERROR: Did not find a class called '#{name}' to create in #{JSON.pretty_generate(STANDARDS_LIST)}"
    end
    OpenStudio.logFree(OpenStudio::Info, 'openstudio.standards.standard', "Using OpenStudio Standards version #{OpenstudioStandards::VERSION} with template #{name}.")
    return STANDARDS_LIST[name].new
  end

  # set up template class variable.
  def intialize
    super()
  end

  # Get the name of the building type used in lookups
  #
  # @param building_type [String] the building type
  # @return [String] returns the lookup name as a string
  # @todo Unify the lookup names and eliminate this method
  def model_get_lookup_name(building_type)
    lookup_name = building_type
    case building_type
      when 'SmallOffice'
        lookup_name = 'Office'
      when 'MediumOffice'
        lookup_name = 'Office'
      when 'LargeOffice'
        lookup_name = 'Office'
      when 'LargeOfficeDetail'
        lookup_name = 'Office'
      when 'RetailStandalone'
        lookup_name = 'Retail'
      when 'RetailStripmall'
        lookup_name = 'StripMall'
      when 'Office'
        lookup_name = 'Office'
    end
    return lookup_name
  end


  # Loads the openstudio standards dataset for this standard.
  # For standards subclassed from other standards, the lowest-level
  # data will override data supplied at a higher level.
  # For example, data from ASHRAE 90.1-2004 will be overriden by
  # data from ComStock ASHRAE 90.1-2004.
  #
  # @return [Hash] a hash of standards data
  def load_standards_database(data_directories = [])
    puts "Loading standards_data for #{template}"
    @standards_data = {}

    # Load the JSON files from each directory
    data_directories.each do |data_dir|
      if __dir__[0] == ':' # Running from OpenStudio CLI
        OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.standard', "Loading JSON files from #{data_dir}")
        embedded_files_relative("#{data_dir}/data/", /.*\.json/).each do |file|
          data = JSON.parse(EmbeddedScripting.getFileAsString(file))
          OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.standard', 'OpenStudio Standards JSON data loading not yet implemented within CLI.')
          # TODO Figure out relative paths for loading JSON directories from OpenStudio CLI
          # data.each_pair do |key, objs|
          #   # Override the template in inherited files to match the instantiated template
          #   objs.each do |obj|
          #     if obj.has_key?('template')
          #       obj['template'] = template
          #     end
          #   end
          #   if @standards_data[key].nil?
          #     OpenStudio.logFree(OpenStudio::Debug, 'openstudio.standards.standard', "Adding #{key} from #{File.basename(file)}")
          #   else
          #     OpenStudio.logFree(OpenStudio::Debug, 'openstudio.standards.standard', "Overriding #{key} with #{File.basename(file)}")
          #   end
          #   @standards_data[key] = objs
          # end
        end
      else
        OpenStudio.logFree(OpenStudio::Debug, 'openstudio.standards.standard', "Loading JSON files from #{data_dir}")
        files = Dir.glob("#{data_dir}/data/*.json").select {|e| File.file? e}
        files.each do |file|
          data = JSON.parse(File.read(file))
          data.each_pair do |key, objs|
            # Override the template in inherited files to match the instantiated template
            objs.each do |obj|
              if obj.has_key?('template')
                obj['template'] = template
              end
            end
            if @standards_data[key].nil?
              OpenStudio.logFree(OpenStudio::Debug, 'openstudio.standards.standard', "Adding #{key} from #{File.basename(file)}")
            else
              OpenStudio.logFree(OpenStudio::Debug, 'openstudio.standards.standard', "Overriding #{key} with #{File.basename(file)}")
            end
            @standards_data[key] = objs
          end
        end
      end
    end

    # Check that standards data was loaded
    if @standards_data.keys.size.zero?
      OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.standard', "OpenStudio Standards JSON data was not loaded correctly for #{template}.")
    end
    return @standards_data
  end
end
