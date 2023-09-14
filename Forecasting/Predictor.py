import pandas as pd
import numpy as np
import os

def TargetDataReader(Loc, FileName):
    Path = os.path.join(Loc, FileName)
    TempWeather = pd.read_csv(Path)
    TempWeather["DeliveryDT"] = pd.to_datetime(TempWeather["DeliveryDT"],
                                             format='%Y-%m-%d %H:%M:%S',
                                             utc=False)

    return TempWeather