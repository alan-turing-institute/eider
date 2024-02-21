import pandas as pd
import numpy as np
from datetime import timedelta

rng = np.random.default_rng(seed=1234)

def make_random_IDs(max_ID, nrows):
    return list(rng.choice(max_ID, nrows))

def make_random_dates(start, end, nrows, replace=True):
    dates = pd.date_range(start, end).to_list()
    return list(rng.choice(dates, size=nrows, replace=replace))

def make_random_bnf_secs(min_sec, max_sec):
    numbers = [str(i).zfill(4) for i in range(min_sec, max_sec)]
    return list(rng.choice(numbers, size=nrows, replace=True))

def make_random_num_prescribed_items(nrows):
    return rng.poisson(2, nrows) + 1

def make_random_diagnois_choice(ranges, with_NA, nrows):
    if with_NA:
        ranges.append("NA")
    return list(rng.choice(ranges, size=nrows))

def make_random_pis_data(max_ID, nrows, start_date, end_date, min_sec, max_sec):
    pis_data = pd.DataFrame({
        'id': make_random_IDs(max_ID=max_ID, nrows=nrows), 
        'paid_date': make_random_dates(start=start_date, end=end_date, nrows=nrows), 
        'bnf_section': make_random_bnf_secs(min_sec=min_sec, max_sec=max_sec), 
        'num_items': make_random_num_prescribed_items(nrows=nrows)
        }, index=range(nrows))
    pis_data.to_csv("./random_pis_data.csv", index=False)

def make_random_ae_data(max_ID, nrows, start_date, end_date, diagnosis_choice):
    ae_data = pd.DataFrame({
    'id': make_random_IDs(max_ID=max_ID, nrows=nrows), 
    'time': make_random_dates(start=start_date, end=end_date, nrows=nrows), 
    'attendance_category': [1]*nrows,
    'diagnosis_1': make_random_diagnois_choice(ranges=diagnosis_choice, with_NA=False, nrows=nrows),
    'diagnosis_2': make_random_diagnois_choice(ranges=diagnosis_choice, with_NA=True, nrows=nrows),
    'diagnosis_3': make_random_diagnois_choice(ranges=diagnosis_choice, with_NA=True, nrows=nrows),
    }, index=range(nrows))
    ae_data.to_csv("./random_ae_data.csv", index=False)

def make_smr04_data(start_date, end_date, nstays, max_ID):
    start_dates = make_random_dates(start=start_date,
                                    end=end_date,
                                    nrows=nstays,
                                    replace=False)
    data_dict = {'id': [], 'admission_date': [], 'discharge_date': [], 'cis_marker': [], 'episode_within_cis': [], 'some_code': []}
    cis_dict = {}
    for stay_idx in range(nstays):
        # pick a start date for the stay
        start_date = start_dates[stay_idx]

        # pick an ID for the stay
        id = rng.choice(max_ID, 1)[0]

        # decide how many episodes to generate
        n_episodes = rng.poisson(1) + 1 # + 1 so we don't get zero

        # Take the next cis_marker (cis = continuous integrated stay)
        # or generate a random starting marker if we haven't hit this ID before
        # Note that the absolute value of the cis_marker is irrelevant
        # also Note that cis_marker values are not unique across the population, only
        # within a particular ID
        if id in cis_dict:
            cis_marker = cis_dict[id] + 1
            cis_dict[id] += 1
        else:
            cis_marker = rng.choice(100) + 1
            cis_dict[id] = cis_marker


        # loop over the episodes
        for episode in range(n_episodes):
            episode_within_cis = episode + 1 # first episode in a stay has episode_within_cis = 1
            # First episode has stay start date as its start
            episode_start_date = start_date

            # Pick a duration in days (this can be zero as an episode might not take the whole day)
            episode_duration = rng.poisson(1)
            episode_end_date = episode_start_date + timedelta(days=episode_duration)

            # Set start_date for the next episode to the end date of this one
            start_date = episode_end_date

            # Add a random code just to demonstrate the kind of features we might want
            code = rng.choice(['a', 'b', 'c', 'd', 'e'])

            # Add the episode to the data dictionary
            data_dict['id'].append(id)
            data_dict['admission_date'].append(episode_start_date)
            data_dict['discharge_date'].append(episode_end_date)
            data_dict['episode_within_cis'].append(episode_within_cis)
            data_dict['some_code'].append(code)
            data_dict['cis_marker'].append(cis_marker)
    smr04 = pd.DataFrame(data_dict, index=range(len(data_dict['id'])))
    smr04.to_csv("./random_smr04_data.csv", index=False)

start_date=pd.to_datetime('2015-01-01')
end_date=pd.to_datetime('2017-12-31')
nrows=100
max_ID=20
min_sec = 101
max_sec = 110
diagnosis_choice = [101, 102, 103, 104]
nstays=100

make_random_pis_data(max_ID=max_ID,
                     nrows=nrows,
                     start_date=start_date,
                     end_date=end_date,
                     min_sec=min_sec,
                     max_sec=max_sec)

make_random_ae_data(max_ID=max_ID, 
                    nrows=nrows, 
                    start_date=start_date, 
                    end_date=end_date, 
                    diagnosis_choice=diagnosis_choice)

make_smr04_data(start_date=start_date, 
                end_date=end_date, 
                nstays=nstays, 
                max_ID=max_ID)
