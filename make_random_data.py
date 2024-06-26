"""
make_random_data.py
-------------------

This Python script is responsible for generating the random data bundled with
the `eider` package.

It will generate the following files:

- inst/extdata/random_ae_data.csv
- inst/extdata/random_ltc_data.csv
- inst/extdata/random_pis_data.csv
- inst/extdata/random_smr04_data.csv
"""

import pandas as pd
import numpy as np
from datetime import timedelta

from pathlib import Path

SEED = 1234

INST_EXTDATA_FOLDER = Path(__file__).parent / "inst" / "extdata"

def make_random_dates(rng, start, end, nrows, replace=True):
    dates = pd.date_range(start, end).to_list()
    return list(rng.choice(dates, size=nrows, replace=replace))

def make_random_diagnosis_choices(rng, diagnosis_ranges, nrows, n=3):
    if n > len(diagnosis_ranges):
        raise ValueError("n must be less than or equal to len(ranges)")

    all_diagnoses = []

    for _ in range(nrows):
        # Randomly generate a number of diagnoses and then pad with empty
        # strings to make a list of length n
        n_diagnoses = rng.choice(range(1, n + 1))
        diagnoses = list(rng.choice(diagnosis_ranges, size=n_diagnoses,
                                    replace=False))
        diagnoses += [""] * (n - n_diagnoses)
        all_diagnoses.append(diagnoses)

    return zip(*all_diagnoses)


def make_random_pis_data(max_ID, nrows, start_date, end_date, bnf_sections):
    rng = np.random.default_rng(seed=SEED)
    pis_data = pd.DataFrame({
        'id': rng.choice(max_ID, nrows),
        'paid_date': make_random_dates(rng=rng, start=start_date,
                                       end=end_date, nrows=nrows), 
        'bnf_section': rng.choice(bnf_sections, nrows),
        'num_items': rng.poisson(2, nrows) + 1,
        }, index=range(nrows))
    # Replace the last 10 lines with the first 10 lines to make the vignette
    # examples look a bit different
    pis_data.iloc[-10:] = pis_data.iloc[:10].values
    pis_data.to_csv(INST_EXTDATA_FOLDER / "random_pis_data.csv", index=False)

def make_random_ae_data(max_ID: int,
                        nrows: int,
                        start_date: pd.Timestamp,
                        end_date: pd.Timestamp,
                        diagnosis_choice: list[int],
                        attendance_categories: list[str]
                        ):
    rng = np.random.default_rng(seed=SEED)
    d1, d2, d3 = make_random_diagnosis_choices(rng=rng,
                                               diagnosis_ranges=diagnosis_choice,
                                               nrows=nrows,
                                               n=3)

    ae_data = pd.DataFrame({'id': rng.choice(a=max_ID, size=nrows), 
                            'date': make_random_dates(rng=rng, start=start_date,
                                                      end=end_date, nrows=nrows), 
                            'attendance_category': rng.choice(attendance_categories, nrows),
                            'diagnosis_1': d1,
                            'diagnosis_2': d2,
                            'diagnosis_3': d3})
    ae_data.to_csv(INST_EXTDATA_FOLDER / "random_ae_data.csv", index=False)

def make_smr04_data(start_date, end_date, nstays, max_ID):
    rng = np.random.default_rng(seed=SEED)
    start_dates = make_random_dates(rng=rng, start=start_date,
                                    end=end_date,
                                    nrows=nstays,
                                    replace=False)
    data_dict = {
        'id': [],
        'admission_date': [],
        'discharge_date': [],
        'cis_marker': [],
        'episode_within_cis': [],
        'admission_type': [],
        'specialty': []
    }
    cis_dict = {}
    # https://publichealthscotland.scot/media/24927/smr04_crib_270323.pdf
    admission_type_list = [10, 11, 12, 18, 19, 20, 21, 22, 31, 32, 33, 34, 35,
                           36, 38, 39, 30, 40, 48]
    specialties = ['CC', 'G1', 'G2', 'G21', 'G22', 'G3', 'G4', 'G5', 'G6',
                   'G61', 'G62', 'G63']

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
        for i in range(n_episodes):
            # First episode has stay start date as its start
            episode_start_date = start_date

            # Pick a duration in days (this can be zero as an episode might not take the whole day)
            episode_duration = rng.poisson(1)
            episode_end_date = episode_start_date + timedelta(days=episode_duration)

            # Set start_date for the next episode to the end date of this one
            start_date = episode_end_date

            # Add in an admission type (which only exists for the first episode
            # within each stay)
            admission_type = rng.choice(admission_type_list) if i == 0 else ""

            # Add in specialty (which exists for all episodes... I think)
            specialty = rng.choice(specialties)

            # Add the episode to the data dictionary
            data_dict['id'].append(id)
            data_dict['admission_date'].append(episode_start_date)
            data_dict['discharge_date'].append(episode_end_date)
            data_dict['cis_marker'].append(cis_marker)
            data_dict['episode_within_cis'].append(i + 1)
            data_dict['admission_type'].append(admission_type)
            data_dict['specialty'].append(specialty)

    smr04 = pd.DataFrame(data_dict, index=range(len(data_dict['id'])))
    smr04.to_csv(INST_EXTDATA_FOLDER / "random_smr04_data.csv", index=False)

def make_ltc_data(start_date, end_date, max_ID):
    rng = np.random.default_rng(seed=SEED)
    conditions = ['asthma', 'diabetes', 'parkinsons']
    data_dict = {'id': [], **{c: [] for c in conditions}}
    for i in range(max_ID):
        data_dict['id'].append(i)
        for c in conditions:
            if rng.random() < 0.2:
                condition_start_date = make_random_dates(rng=rng, start=start_date,
                                                         end=end_date, nrows=1)[0]
                condition_start_date = condition_start_date.strftime("%Y-%m-%d")
            else:
                condition_start_date = ""
            data_dict[c].append(condition_start_date)
    df = pd.DataFrame(data_dict)
    df.to_csv(INST_EXTDATA_FOLDER / "random_ltc_data.csv", index=False)

# https://publichealthscotland.scot/services/national-data-catalogue/data-dictionary/a-to-z-of-data-dictionary-terms/attendance-category-ae/

start_date = pd.to_datetime('2015-01-01')
end_date = pd.to_datetime('2017-12-31')
nrows = 100
max_ID = 20
bnf_sections = numbers = [str(i).zfill(4) for i in range(101, 120)]
diagnosis_choice = list(range(0, 20)) + [99] 
attendance_categories = ["01", "02", "03", "04", "05"]
nstays = 100

make_random_pis_data(max_ID=max_ID,
                     nrows=nrows,
                     start_date=start_date,
                     end_date=end_date,
                     bnf_sections=bnf_sections)

make_random_ae_data(max_ID=max_ID, 
                    nrows=nrows, 
                    start_date=start_date, 
                    end_date=end_date, 
                    diagnosis_choice=diagnosis_choice,
                    attendance_categories=attendance_categories)

make_smr04_data(start_date=start_date, 
                end_date=end_date, 
                nstays=nstays, 
                max_ID=max_ID)

make_ltc_data(start_date=start_date, 
              end_date=end_date, 
              max_ID=max_ID)
