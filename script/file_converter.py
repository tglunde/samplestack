""" 
This class does key-value-modifications on existing zip/json files. 
To start, the path to the zip-file must be entered when calling the class. Second parameter(s) is a key-value-pair(s).
"""
# all imports
import json
import os 
import glob
import zipfile
import argparse
import sys
import tempfile # to get the directory with temporary files
import shutil


class file_converter:
    # assert statement is supposed to be true. If false, assert will stop the program and give an AssertionError in addition with the customized error message.
    
    # this is the constructor, which is always executed when the class is being initiated.
    def __init__(self, path_to_zip_file): 
        assert os.path.exists(path_to_zip_file), "Zip file does not exist or path is wrong." # if files does not exist, stop program
        
        # creates a unique temp file (thus, two instances of this class could run at the same time)
        self.path_to_extract_file = tempfile.mkdtemp(dir = os.path.dirname(path_to_zip_file)) 
        self.path_to_zip_file = path_to_zip_file
        
        ###################
        ### unzip file ###
        with zipfile.ZipFile(path_to_zip_file, "r") as zip_ref:
            zip_ref.extractall(self.path_to_extract_file)

        assert os.path.exists(self.path_to_extract_file), "Could not extract files."
        print("Extracted files to \"%s\"." % self.path_to_extract_file)
        ###################

    def __init__(self):
        self.path_to_extract_file = './dvb/'

    # modify db type in version file
    def replaceDBType(self, db_type = "snowflake"): # defaults "db_type"
        path_to_version_file = os.path.join(self.path_to_extract_file, "version.json") # concatenate two paths
        valid_db_types = ["oracle", "exasol", "snowflake", "postgres", "mssql"] # all compatible db types so far
        assert db_type in valid_db_types, "\"%s\" is not a valid db type." % db_type # if db_type does not occur in valid_db_types, stop program
        self.db_type = db_type
        
        assert os.path.exists(path_to_version_file), "File \"%s\" does not exist." % os.path.basename(path_to_version_file) # if files does not exist, stop program
        print("\n------Processing file: %s------" % os.path.basename(path_to_version_file)) # print file name

        with open(path_to_version_file) as v: # open and read file
            version_data = json.load(v) # deserialize json object to a python object
        
        self.nestedReplace(version_data, "client_db_type_id", self.db_type) # call function to replace
        
        with open(path_to_version_file, "w", newline ="\n") as v: # open, read and write file
            version_txt = json.dumps(version_data, indent=4, sort_keys=True) # convert from python object to json object
            v.write(version_txt)
        print("db type is set to \"%s\". " % self.db_type)

        ################################################################################
        ### this part opens the file just to test whether the replacements were made ###
        with open(path_to_version_file) as test_file:
            test_file_data = json.load(test_file) # deserialize json object to a python object

        if test_file_data != []: # in case there is an empty json file
            self.checkReplacement(test_file_data, "client_db_type_id", self.db_type) # call function to check replacements
        #else: print("test json is empty")    
        ################################################################################


    # get a list of all files
    def getFileList(self, keys_values):
        self.keys_values = keys_values
        path = os.path.join(self.path_to_extract_file, "datavaultbuilder_objects/")
        
        all_files_path = []
        # r=root, d=directories, f=files
        for r, d, f, in os.walk(path): # get all file paths and append it to all_files_path-array
            for file in f:
                all_files_path.append(os.path.join(r, file))

        for file_path in all_files_path:
            assert os.path.exists(file_path), "File \"%s\" does not exist or path is wrong." % os.path.basename(file_path) # if file does not exist, stop the program
            print("\n------Processing file: %s------" % os.path.basename(file_path)) # print file name that is going to be processed

            for key_value in self.keys_values:
                #print("Key: %r, Value: %r" % (key_value, self.keys_values[key_value])) #print key-value pairs
                self.writeFile(file_path, key_value, self.keys_values[key_value]) #pass file path and key value pairs to function
        print("All replacements complete.")                
                

    def renameFileLower(self):
        path = os.path.join(self.path_to_extract_file, "datavaultbuilder_objects/")
        
        all_files_path = []
        # r=root, d=directories, f=files
        for r, d, f, in os.walk(path): # get all file paths and append it to all_files_path-array
            for file in f:
                all_files_path.append(os.path.join(r, file))

        for file_path in all_files_path:
            assert os.path.exists(file_path), "File \"%s\" does not exist or path is wrong." % os.path.basename(file_path) # if file does not exist, stop the program
            os.rename(file_path, file_path.lower())

        print("Rename to lower compmlete.")                


    # open, call function to replace values and write the files
    def writeFile(self, file_path, key, value):
        # open file and assign JSON to variable "file_data"
        with open(file_path) as file:
            file_data = json.load(file) # deserialize json object to a python object

        self.nestedReplace(file_data, key, value) # call function to replace
        
        # open file, sort & indent JSON from "file_data" and assign it as String to "data_txt". Finally, overwrite opened file "file_to_write" with "data_txt"
        with open(file_path, "w", newline ="\n") as file_to_write: # open, read and write file
            data_txt = json.dumps(file_data, indent=4, sort_keys=True) # convert from python object to json object
            file_to_write.write(data_txt)
        
        ################################################################################
        ### this part opens the file just to test whether the replacements were made ###
#        with open(file_path) as test_file:
#            test_file_data = json.load(test_file) # deserialize json object to a python object
        
#        if file_data != []: # in case there is an empty json file
#            self.checkReplacement(test_file_data, key, value) # call function to check replacements
        #else: print("test json is empty")
        ################################################################################

    def fileConversion(self, keys, conversion):
        self.keys = keys
        path = os.path.join(self.path_to_extract_file, "datavaultbuilder_objects/")
        
        all_files_path = []
        # r=root, d=directories, f=files
        for r, d, f, in os.walk(path): # get all file paths and append it to all_files_path-array
            for file in f:
                all_files_path.append(os.path.join(r, file))

        for file_path in all_files_path:
            assert os.path.exists(file_path), "File \"%s\" does not exist or path is wrong." % os.path.basename(file_path) # if file does not exist, stop the program
            print("\n------Processing file: %s------" % os.path.basename(file_path)) # print file name that is going to be processed

            for key in self.keys:
                with open(file_path) as file:
                    file_data = json.load(file) # deserialize json object to a python object

                self.nestedConvert(file_data, key, conversion) # call function to replace
                
                # open file, sort & indent JSON from "file_data" and assign it as String to "data_txt". Finally, overwrite opened file "file_to_write" with "data_txt"
                with open(file_path, "w", newline ="\n") as file_to_write: # open, read and write file
                    data_txt = json.dumps(file_data, indent=4, sort_keys=True) # convert from python object to json object
                    file_to_write.write(data_txt)

        print("All conversions complete.")                


    def lower(self, json, k):
        if(isinstance(json[k], str)):
            json[k] = json[k].lower()

    def upper(self, json, k):
        if(isinstance(json[k], str)):
            json[k] = json[k].upper()

    def nestedConvert(self, json, k, conversion):
        if json != [] and json is not None: # in case there is an empty json file
            if isinstance(json, list): # check if json is a list (because a json could be a list or a dict at the beginning)
                for j in json:
                    self.nestedConvert(j, k, conversion)
            else: # if json is not a list
                for key in json.keys(): # iterate through all keys in dict
                    if json[key] != []:
                        if key == k:
                            conversion(json,key)
                        if isinstance(json[key], dict): # check if key is a dictionary
                            self.nestedConvert(json[key], k, conversion)
                        if isinstance(json[key], list): # check if key is a list
                            for j in json[key]:
                                self.nestedConvert(j, k, conversion)
                    else: print("Empty json. Key: %s" % key)


    # iterates through json structure and searches for the key-value pair(s) that was entered
    def nestedReplace(self, json, k, v):
        if json != [] and json is not None: # in case there is an empty json file
            if isinstance(json, list): # check if json is a list (because a json could be a list or a dict at the beginning)
                for j in json:
                    self.nestedReplace(j, k, v)
            else: # if json is not a list
                for key in json.keys(): # iterate through all keys in dict
                    if json[key] != []:
                        if key == k:
                            if json[key] is None: # means, when a key-value pair looks like this: "someKey": null
                                json[key] = v # assign to json object
                            ####compatible_values = [maybe create an array with values that does not have to be changed, e.g. DECIMAL and so on and then parse through that array??]####
                            # int handling
                            if isinstance(json[key], int): # check if key is an integer
                                # only change value, if it does not equal the entered one and if "DECIMAL" does not occur in the value
                                if json[key] != v:
                                    json[key] = v # assign to json object
                            elif json[key] != v and "DECIMAL" not in json[key]: #only change value, if it is not as entered and if "DECIMAL" does not occur in the value
                                json[key] = v # assign to json object
                        if isinstance(json[key], dict): # check if key is a dictionary
                            self.nestedReplace(json[key], k, v)
                        if isinstance(json[key], list): # check if key is a list
                            for j in json[key]:
                                self.nestedReplace(j, k, v)
                    else: print("Empty json. Key: %s" % key)

    
    # ONLY FOR CHECKING REPLACEMENTS: iterates through json structure and searches for the key-value pair(s) that was entered
    def checkReplacement(self, json, k, v):
        if json != [] and json is not None: # in case there is an empty json file
            if isinstance(json, list): # check if json is a list (because a json could be a list or a dict at the beginning)
                for j in json:
                    self.nestedReplace(j, k, v)
            else: # if json is not a list
                for key in json.keys(): # iterate through all keys in dict
                    if json[key] != []:
                        if key == k:
                            if json[key] is None: # means, when a key-value pair looks like this: "someKey": null
                                json[key] = v # assign to json object
                            ####compatible_values = [maybe create an array with values that does not have to be changed, e.g. DECIMAL and so on.]?####
                            # int handling
                            if isinstance(json[key], int): # check if key is an integer
                                # only check value, if it does not equal the entered one and if "DECIMAL" does not occur in the value
                                if json[key] != v:
                                    #print("Current Value: %s" % json[key])
                                    assert json[key] == v, "Value has not been replaced. Current value is \"%s\". Current Value: %s" % json[key]
                            elif json[key] == v and "DECIMAL" not in json[key]: #only check value, if it is not as entered and if "DECIMAL" does not occur in the value
                                #print("Current Value: %s" % json[key])
                                assert json[key] == v, "Value has not been replaced. Current value is \"%s\"" % json[key]
                        if isinstance(json[key], dict): # check if key is a dictionary
                            self.checkReplacement(json[key], k, v)
                        if isinstance(json[key], list): # check if key is a list
                            for j in json[key]:
                                self.checkReplacement(j, k, v)
                

    # this function is for the test class 'TestFileConverter.py' to delete all files created while testing this script
    def deleteTestFiles(self):
        shutil.rmtree(self.path_to_extract_file)
        print("Successfully deleted test files.")