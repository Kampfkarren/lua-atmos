local Constants = {}

--important math constants
Constants.ATMOSPHERE = 101.325 --one atmosphere in kPa
Constants.MINIMUM_HEAT_CAPACITY = 0.0003

Constants.TEMPERATURE_OF_SPACE = -270.45 --C
Constants.TEMPERATURE_WORTH_WORRYING = 0.3 --any temperature difference <= this will not be checked
Constants.TIDAL_VOLUME = 0.5 --litres of air an adult human breathes in one breath

--pressure
--WEIRD NUMBERS WEIRD NUMBERS
Constants.IDEAL_GAS_CONSTANT = 8.314 --R in pV = nRT. measured in kPa*L/(K*mol)
Constants.CELL_VOLUME = 0.3 --area volume = cell_volume * cells

return Constants
