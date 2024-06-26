import osgeo.gdal as gdal
import osgeo.ogr as ogr
import os, sys
import itertools
 
# Following for xml output
# xmlgen.py script required in same folder
from xmlgen import XMLWriter
 
def startup():
  gdal.PushErrorHandler()
  skiplist = ['.svn','.shx','.dbf']
  startpath = sys.argv[1]
  pathwalker = os.walk(startpath)
  walkers = itertools.tee(pathwalker)
  counterraster = 0
  countervds = 0
  writer = XMLWriter()
  writer.push("DataCatalogue")
#  walkerlist = list(copy.pathwalker)
  processStats(writer, walkers[1], skiplist, startpath)
  for eachpath in walkers[0]:
    startdir = eachpath[0]
    alldirs = eachpath[1]
    allfiles = eachpath[2]
    for eachdir in alldirs:
      currentdir = os.path.join(startdir,eachdir)
      #print currentdir
      raster,vector = tryopends(currentdir)
      if (not skipfile(currentdir,skiplist) and tryopends(currentdir)):
        raster,vector = tryopends(currentdir)
        if raster:
          counterraster += 1
         # print counterraster
          resultsraster = processraster(raster,counterraster)
          xmlraster = outputraster(writer, resultsraster, counterraster, countervds)
        if vector:
          countervds += 1
          resultsvds = processvds(vector,countervds)
          xmlvector = outputvector(writer, resultsvds,counterraster,countervds)
    for eachfile in allfiles:
      currentfile = "/".join([startdir, eachfile])
      #print "Current file" + currentfile
      if (not skipfile(currentfile,skiplist) and tryopends(currentfile)):
        raster, vector = tryopends(currentfile)
      if raster:
        counterraster += 1
        resultsraster = processraster(raster, counterraster)
        xmlraster = outputraster(writer, resultsraster, counterraster, countervds)
      if vector:
        if (not skipfile(vector.GetName(),skiplist)):
          countervds += 1
          resultsvds = processvds(vector,countervds)
          xmlvector = outputvector(writer, resultsvds,counterraster,countervds)
  writer.pop()
 
def processStats(writer, walkerlist, skiplist, startpath):
  from time import asctime
  #walkerList = list(pathwalker)
  dirlist, filelist = [], []
  for entry in walkerlist:
    dirlist += entry[1]
    filelist += entry[2]
  writer.push("CatalogueProcess")
  writer.elem("SearchPath", startpath)
  writer.elem("LaunchPath", os.getcwd())
  writer.elem("UserHome", os.getenv("HOME"))
  writer.elem("IgnoredStrings", str(skiplist))
  writer.elem("DirCount", str(len(dirlist)))
  writer.elem("FileCount", str(len(filelist)))
  writer.elem("Timestamp", asctime())
  writer.pop()
def skipfile(filepath, skiplist):
  skipstatus = None
  for skipitem in skiplist:
    if filepath.find(skipitem) > 0: 
      skipstatus = True
      return True
    else:
      skipstatus = False
  return skipstatus
 
def tryopends(filepath):
  dsogr, dsgdal = False, False
  try:
    #print "trying" + filepath
    dsgdal = gdal.OpenShared(filepath)
  except gdal.GDALError:
    return False
  try:
    dsogr = ogr.OpenShared(filepath)
  except ogr.OGRError:
    return False
  return dsgdal, dsogr
 
def processraster(raster, counterraster):
  rastername = raster.GetDescription()
  bandcount = raster.RasterCount
  geotrans = raster.GetGeoTransform()
  driver = raster.GetDriver().LongName
  rasterx = raster.RasterXSize
  rastery = raster.RasterYSize
  wkt = raster.GetProjection()
  resultsbands = {}
  for bandnum in range(bandcount):
    band = raster.GetRasterBand(bandnum+1)
    min, max = band.ComputeRasterMinMax()
    overviews = band.GetOverviewCount()
    resultseachband = {'bandId': str(bandnum+1), 'min': str(min),'max': str(max), 'overviews': str(overviews)}
    resultsbands[str(bandnum+1)] = resultseachband
  resultsraster = { 'bands': resultsbands, 'rasterId': str(counterraster), 'name': rastername, 'boundcount': str(bandcount), 'geotrans': str(geotrans), 'driver': str(driver), 'rasterX': str(rasterx), 'rasterY': str(rastery), 'project': wkt}
  return resultsraster
 
def outputraster(writer, resultsraster, counterraster, countervds):
  writer.push(u"RasterData")
  for rasteritem, rastervalue in resultsraster.iteritems(): # for each raster attribute
    if rasteritem <> 'bands':
      writer.elem(unicode(rasteritem), unicode(rastervalue))
    if rasteritem == 'bands':
      for banditem, bandvalue in rastervalue.iteritems(): # for each band
        writer.push(u"RasterBand")
        for banditemdetails, bandvaluedetails in bandvalue.iteritems():
          writer.elem(unicode(banditemdetails), unicode(bandvaluedetails))
        writer.pop()
  writer.pop()
  return True
 
def processvds(vector, countervds):
  vdsname = vector.GetName()
  vdsformat = vector.GetDriver().GetName()
  vdslayercount = vector.GetLayerCount()
  resultslayers = {}
  for layernum in range(vdslayercount): #process all layers
    layer = vector.GetLayer(layernum)
    layername = layer.GetName()
    layerfcount = str(layer.GetFeatureCount())
    layerextentraw = layer.GetExtent()
 
    # the following throws all the attributes into dictionaries of attributes, 
    # some of which are other dictionaries
    # resultseachlayer = 1 layer attributes
    # resultslayers = dict. of all layers and their attributes
    # resultsvds = datasource attributes
    # resultsvector = dict of datasource attributes, plus a dict of all layers
    resultseachlayer = {'layerId': str(layernum+1), 'name': layername, 'featurecount': str(layerfcount), 'extent': layerextentraw}
    resultslayers[str(layernum+1)] = resultseachlayer
  resultsvds = { 'datasourceId': str(countervds), 'name': vdsname, 'format': vdsformat, 'layercount': str(vdslayercount) }
  resultsvector = { 'resultsvds': resultsvds, 'resultslayers': resultslayers } 
  return resultsvector
 
def outputvector(writer, resultsvector, counterraster, countervds):
  writer.push(u"VectorData")
  for vectoritem, vectorvalue in resultsvector.iteritems(): # resultsvector includes two dictionaries
    if vectoritem <> 'resultslayers':
      for vectordsitem, vectordsvalue in vectorvalue.iteritems(): # vectorvalue contains datasource attributes
        writer.elem(unicode(vectordsitem), unicode(vectordsvalue))
    if vectoritem == 'resultslayers':
      for layeritem, layervalue in vectorvalue.iteritems(): # vectorvalue contains a dictionary of the layers
        writer.push(u"VectorLayer")
        for layeritemdetails, layervaluedetails in layervalue.iteritems(): # layervalue contains layer attributes
          writer.elem(unicode(layeritemdetails), unicode(layervaluedetails))
        writer.pop()
  writer.pop()
  return True
 
def checkZip(currentfile):
  import zipfiles
  # check if it can read zips
 
def openZip(currentfile):
  import zipfiles
  # extract files and catalogue them
 
if __name__ == '__main__':
  startup()
