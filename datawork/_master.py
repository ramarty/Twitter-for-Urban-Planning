# -*- coding: utf-8 -*-
"""
Created on Tue Jul  2 10:07:05 2019

@author: WB521633
"""

# Setup -----------------------------------------------------------------------
# Setup Project Filepath
project_dir = 'C:/Users/wb521633/Dropbox/World Bank/IEs/smarTTrans Algorithm Technical Paper'

# Load Packages
import json, re
from shapely.geometry import MultiPoint
import os
import sys
import pandas as pd
import numpy as np
import re
import pyreadr
import itertools as IT
import collections
import string
#import centerline
import geopandas as gpd
import osmnx as ox
import networkx as nx

# For some reason need to run this multiple times to get working
os.chdir(r'' + project_dir + '/functions_and_packages/LNEx')
sys.path.append(r'' + project_dir + '/functions_and_packages/LNEx')
import LNEx as lnex

os.chdir(r'' + project_dir + '/functions_and_packages/LNEx/LNEx')
sys.path.append(r'' + project_dir + '/functions_and_packages/LNEx/LNEx')
import LNEx as lnex

os.chdir(r'' + project_dir + '/functions_and_packages/LNEx')
sys.path.append(r'' + project_dir + '/functions_and_packages/LNEx')
import LNEx as lnex

import gaz_augmentation_and_filtering as LNEx_aug
