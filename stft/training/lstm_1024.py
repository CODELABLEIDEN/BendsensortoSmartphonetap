#!/usr/bin/env python
# coding: utf-8

# # Data preparation

# In[1]:


import math
import random
import copy

import keras
import h5py


# # Read hdf5

# In[2]:


def get_data(filename):
    """
    Read data from hdf5 file
    Create a list of the lowest level keys, the name of the data files
    Return both data and list
    """
    data = h5py.File(filename, "r")
    files = []
    for participant in data:
        for window in data[participant]:
            keys = list(data[f'/{participant}/{window}'].keys())
            files.append((f'{participant}/{window}/{keys[0]}',f'{participant}/{window}/{keys[1]}'))
    return (data,files)


# In[110]:


def standardize(bs,fs):
    """
    Standardize input data with mean=0 and std=1
    """
    scaler_bs = StandardScaler()
    bs_array_std = scaler_bs.fit_transform(bs)

    scaler = StandardScaler()
    fs_array_std = scaler.fit_transform(fs)
    return (bs_array_std,fs_array_std)


# # Generator

# In[116]:


class BatchGenerator(object):

    def __init__(self, data, indexes, samples, num_features_bs, num_features_fs, timesteps, max_random_count=1000, standardize_fun=standardize):
        # data as h5 file
        self.data = data
        # file names from data to read

        # Batch shape (samples x timesteps x features)
        self.samples = samples
        context = 5
        self.timesteps = timesteps
        self.num_features_bs = num_features_bs
        self.num_features_fs = num_features_fs

        # initialize sequences to be rewritten with data from each p
        self.input_seq = 0
        self.output_seq = 0

        # index keeps track of where the timesteps starts
        self.current_idx = 0

        # completed is whether it went once all over the batches
        self.completed = False
        # index of how many randomly generated batches has been created
        self.random_count = 0
        # max number of random sequences to be generated default is 1000
        self.max_random_count = max_random_count
        self.indexes = indexes
        copy_indexes = copy.deepcopy(self.indexes)
        for participant in copy_indexes:
            random.shuffle(copy_indexes[participant])
        self.copy_indexes = copy_indexes


    def generate(self):
        while True:
            #print(f'current p {self.current_p}')
            if self.random_count == self.max_random_count:
                #print(f'random count {self.random_count}')
                self.random_count = 0
                self.completed = False

            if self.completed:
                self.random_count =  self.random_count + 1


            participant = random.randint(0,len(self.copy_indexes.keys())-1)
            filenames = list(self.copy_indexes.keys())[participant]

            if self.random_count > 0:
                index = self.copy_indexes[filenames].pop()
            else:
                # reset the index back to the start of the data set
                random_start_idx = random.randint(self.indexes[filenames][0][0],self.indexes[filenames][-1][0])
                index = (random_start_idx, random_start_idx+self.samples*self.timesteps)


            if not len(self.copy_indexes[filenames]):
                del self.copy_indexes[filenames]
                if not len(list(self.copy_indexes.keys())):
                    self.completed = True
                    self.copy_indexes = copy.deepcopy(self.indexes)
                    for participant in self.copy_indexes:
                        random.shuffle(self.copy_indexes[participant])

            bs = np.transpose(np.array(data[filenames[0]]))[index[0]:index[1]]
            fs = np.transpose(np.array(data[filenames[1]]))[index[0]:index[1]]
            bs_std,fs_std = standardize(bs,fs)
            # reshape as SamplesxTimestepsxFeatures
            batch_x = bs.reshape(self.samples,self.timesteps, self.num_features_bs)
            batch_y = fs.reshape(self.samples,self.timesteps, self.num_features_fs)
            # shuffle samples
            x, y = shuffle(batch_x, batch_y, random_state=0)
            yield x,y


# In[126]:



# # Train test split

# In[5]:


def generate_indexes(data_type):
    indexes = {}
    for file in files:
        if data_type == "train":
            start = 0
            end = np.shape(data[file[0]])[1] * 0.8
        elif data_type == "val":
            start = np.shape(data[file[0]])[1] * 0.8
            end = np.shape(data[file[0]])[1] * 0.9
        else:
            start = np.shape(data[file[0]])[1] * 0.9
            end = np.shape(data[file[0]])[1]
        indexes[file] = [(start_idx,start_idx+(timesteps*samples)) for start_idx in range(round(start),round(end),(timesteps*samples)) if start_idx+(timesteps*samples) <round(end)]
    return indexes


# # Train model

# In[6]:


def get_len_train(data, files, data_percentage):
    """
    Gets the length of all the data from all participants
    Takes the data and all filenames as array
    """
    total_len = 0
    for filename in files:
        # index the size from fs (filename[1]) to avoid having to read BS which is larger
        total_len = total_len + np.shape(np.array(data[filename[1]]))[1]
    # since this is used for train, test and val data which is not the total length
    # multiply the total length by the percentage of the data used in those sets
    # (e.g. 0.2 for 20 percent validation data)
    total_len = total_len*data_percentage
    return total_len


# In[117]:
if __name__ == '__main__':

    # model parameters
    filename = "stft_1024_with_rms.h5"
    #filename = "../lstm_data/ds_data_new.h5"
    data, files = get_data(filename)
    np.shape(data[files[0][0]])
    samples = 10
    timesteps = 1
    num_features_bs = np.shape(data[files[0][0]])[0]
    num_features_fs = np.shape(data[files[0][1]])[0]
    max_random_count = 100

    # calculate steps
    total_len_train = get_len_train(data, files,0.8)
    total_len_val = get_len_train(data, files,0.1)
    steps_per_epoch = math.ceil(total_len_train / (timesteps*samples)) + (len(files) * max_random_count)
    validation_steps = math.ceil(total_len_val / (timesteps*samples))

    print(steps_per_epoch)
    print(validation_steps)

    # initialize generators
    train_indexes = generate_indexes("train")
    val_indexes = generate_indexes("val")
    test_indexes = generate_indexes("test")

    train_data_generator = BatchGenerator(data, train_indexes, samples, num_features_bs, num_features_fs, timesteps, max_random_count=max_random_count)
    val_data_generator = BatchGenerator(data, val_indexes, samples, num_features_bs, num_features_fs,  timesteps, max_random_count=max_random_count)
    test_data_generator = BatchGenerator(data, test_indexes, samples, num_features_bs, num_features_fs, timesteps, max_random_count=max_random_count)


    # In[9]:


    checkpoint_filepath = 'stft_1024_with_rms.hd5'
    model_checkpoint_callback = keras.callbacks.ModelCheckpoint(
        filepath=checkpoint_filepath,
        save_weights_only=True,
        monitor='val_loss',
        mode='max',
        save_best_only=True)


    # In[118]:


    # BiLSTM
    model = keras.Sequential()

    model.add(keras.layers.Bidirectional(keras.layers.LSTM(256, return_sequences=True), input_shape=(timesteps,num_features_bs)))
    model.add(keras.layers.Bidirectional(keras.layers.LSTM(128, return_sequences=True)))
    model.add(keras.layers.Dense(num_features_fs))

    model.summary()
    model.compile(loss='mse', optimizer='adam')


    # In[119]:


    model.fit_generator(train_data_generator.generate(), steps_per_epoch= steps_per_epoch, epochs=1, verbose=2,
              validation_data=val_data_generator.generate(), validation_steps=validation_steps,
              callbacks=[model_checkpoint_callback])


    # serialize model to json
    json_model = model.to_json()
    #save the model architecture to JSON file
    with open('stft_1024_with_rms.json', 'w') as json_file:
        json_file.write(json_model)
    #saving the weights of the model
    model.save_weights('stft_1024_with_rms_weights.h5')
