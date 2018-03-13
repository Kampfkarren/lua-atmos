local Constants = {}

--important math constants
Constants.ATMOSPHERE = 101.325 --one atmosphere in kilopascals
Constants.IDEAL_GAS_CONSTANT = 8.314 --R in pV = nRT. measured in kPa*L/(K*mol)
Constants.MINIMUM_HEAT_CAPACITY = 0.0003

Constants.TEMPERATURE_OF_SPACE = -270.45 --C
Constants.TEMPERATURE_WORTH_WORRYING = 0.3 --any temperature difference <= this will not be checked
Constants.TIDAL_VOLUME = 0.5 --litres of air an adult human breathes in one breath

return Constants
