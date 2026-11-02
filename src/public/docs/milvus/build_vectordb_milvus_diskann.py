# %%
import os
#os.environ["CUDA_VISIBLE_DEVICES"] = "0"
import time
import glob
import json
import numpy as np
from tqdm import tqdm
from pymilvus import connections, FieldSchema, CollectionSchema, DataType, Collection, utility
from sentence_transformers import SentenceTransformer

model_folder = '/home/shared/HuggingFace/models/'
embed_name = model_folder + "Alibaba-NLP/gte-large-en-v1.5"
dataset_name = 'scifact'
batch_size = 32
collection_name = 'SciFact_RAG'

# %%
def main(dataset_name, embed_name, batch_size, collection_name):
    start_time = time.time()
    data_folder = '/media/lurker18/HardDisk1/HuggingFace/datasets/AllenAI/'
    encoder = SentenceTransformer(embed_name, trust_remote_code = True)
    connections.connect(host = "localhost", port = "19530", token = "<username>:<password>")
    dim = 1024
    collection_name = collection_name
    
    index_params = {
        "index_type" : "DISKANN",
        "metric_type": "IP"
    }
    
    fields = [
        FieldSchema(name = 'id', dtype = DataType.VARCHAR, is_primary = True, auto_id = False, max_length = 65535),
        FieldSchema(name = 'title', dtype = DataType.VARCHAR, max_length = 65535),
        FieldSchema(name = 'content', dtype = DataType.VARCHAR, max_length = 65535),
        FieldSchema(name = 'vector', dtype = DataType.FLOAT_VECTOR, dim = dim),
    ]
    schema = CollectionSchema(fields = fields)
    collection = Collection(name = collection_name, schema = schema)
    collection.create_index(field_name = "vector", index_params = index_params)
    collection.load()

    if dataset_name == 'wikipedia':
        dataset_name = data_folder + 'wikipedia/chunk'
    elif dataset_name == 'statpearls':
        dataset_name = data_folder + 'statpearls/chunk'
    elif dataset_name == 'textbooks':
        dataset_name = data_folder + 'textbooks/chunk'
    elif dataset_name == 'pubmed':
        dataset_name = data_folder + 'pubmed/chunk'
    elif dataset_name == 'biomed':
        dataset_name = data_folder + 'biomed/chunk'
    elif dataset_name == 'scifact':
        dataset_name = data_folder + 'Scifact_RAG/chunk'

    # Use glob to find all .jsonl files in the folder
    file_paths = glob.glob(f"{dataset_name}/*.jsonl")
    print(f"{dataset_name.split('/')[-2]}---Total Counts:{len(file_paths)}")

    for file_path in tqdm(file_paths, desc = "Finished JSON"):
        data = []
        with open(file_path, 'r') as file:
            file_data = [json.loads(line) for line in file]

            indexs = [doc['id'] for doc in file_data] # IDs
            titles = [doc['title'] for doc in file_data] # Titles
            contents = [doc['content'] for doc in file_data] # Contents

            try:
                vectors = encoder.encode(contents, 
                                         batch_size = batch_size)  # Adjust batch_size as needed
                
                data = [{"id" : str(idx), 
                         "title" : title,
                         "content" : doc[:65500] if len(doc) > 65535 else doc,
                         "vector" : vector.tolist()}
                        for idx, title, doc, vector in zip(indexs, titles, contents, vectors)]
                
                for row in iter(data):
                    collection.upsert(row)
            
            except:
                print(file_path)
                continue

    print("---Completed Loading and Storing Database!---")
    print(f"Elapsed seconds: {time.time()-start_time:.0f} Record count: {collection.num_entities}")

main(dataset_name, embed_name, batch_size, collection_name)

# %%
connections.connect(host = "localhost", port = "19530")
collection = Collection(name = collection_name)
collection.load()
encoder = SentenceTransformer(embed_name, trust_remote_code = True)
search_params = {"metric_type": "IP", 
                 "params": {"search_list" : 16}}
# %%
res = collection.search(
    anns_field = "vector",
    param = search_params,
    data = encoder.encode(["What is anarchism?"]),
    limit = 1,
    output_fields = ["id", "content"],
)
# %%
print(res)
# %%
