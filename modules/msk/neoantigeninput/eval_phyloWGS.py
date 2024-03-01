import json
import sys 
import pandas as pd
# TODO: Make sure vcflib is in path
sys.path.insert(0,'/Users/orgeraj/Documents/GitHub/vcflib/')
import vcflib
import argparse



def main(args):
    
    def makeChild(subTree):
        newsubtree = {'clone_id':int(subTree),
        'clone_mutations': [],
        "children":[],
        'X' : 0,
        'x' : 0 , 
        'new_x': 0}

        if str(subTree) in trees[tree]['structure']:
            for item in trees[tree]['structure'][str(subTree)]:
                # print(item)    
                if str(subTree) in trees[tree]['structure']:
                    
                    child_dict = makeChild(item)
                    newsubtree['children'].append(child_dict)
                    
            try:
                ssmli = []
                for ssm in treefile['mut_assignments'][str(subTree)]['ssms']:
                    ssmli.append(chrom_pos_dict[mut_data['ssms'][ssm]['name']]['id'])
                newsubtree['clone_mutations']= ssmli    
                newsubtree['X']=trees[tree]['populations'][str(subTree)]['cellular_prevalence'][0]
                newsubtree['x']=trees[tree]['populations'][str(subTree)]['cellular_prevalence'][1]
                newsubtree['new_x']=0.0
            except Exception as e:
                print("Error in adding new subtree. Error not in base case")
                print(e)
                pass
            
            return newsubtree        
            
        else:
            #Base Case
            #make childrendict and return it
            ssmli = []
            
            for ssm in treefile['mut_assignments'][str(subTree)]['ssms']:
                print(mut_data['ssms'][ssm]['name'])
                try:
                    ssmli.append(chrom_pos_dict[mut_data['ssms'][ssm]['name']]['id'])
                except Exception as e:
                    print("Error in appending to mutation list. Error in base case")
                    print(e)
                    pass
                
            try:
                newsubtree['clone_mutations']= ssmli 
                newsubtree['X']=trees[tree]['populations'][str(subTree)]['cellular_prevalence'][0]
                newsubtree['x']=trees[tree]['populations'][str(subTree)]['cellular_prevalence'][1]
                newsubtree['new_x']=0.0
            except Exception as e:
                print("Error in adding new subtree. Error in base case")
                print(e)
                pass
            
            
            
            return newsubtree
        
        
    
    with open(args.summary_file, 'r') as f:
        # Load the JSON data into a dictionary
        summ_data = json.load(f)

    with open(args.mutation_file, 'r') as f:
        # Load the JSON data into a dictionary
        mut_data = json.load(f)
        
        
        
    
    chrom_pos_dict = {}
    mutation_list = []
    
    
    mafdf = pd.read_csv(args.maf_file, delimiter='\t')

    for index,row in mafdf.iterrows():
        if row['Variant_Type'] == 'SNP':
            if row['Variant_Classification'] == "Missense_Mutation":
                missense = 1
                
            else:
                missense= 0
            
            if row['Variant_Type'] == 'SNP':
                
                chrom_pos_dict['id': row['Chromosome']+'_'+str(row['Start_Position'])+'_'+row['Reference_Allele']+'_'+row['Tumor_Seq_Allele2']]= {'id': row['Chromosome']+'_'+str(row['Start_Position'])+'_'+row['Reference_Allele']+'_'+row['Tumor_Seq_Allele2'],
                                                                                'gene': row['Hugo_Symbol'],
                                                                                "missense": missense}
                
                mutation_list.append({'id': row['Chromosome']+'_'+str(row['Start_Position'])+'_'+row['Reference_Allele']+'_'+row['Tumor_Seq_Allele2'],
                                                                                'gene': row['Hugo_Symbol'],
                                                                                "missense": missense})
            elif row['Variant_Type'] == 'DEL':
                chrom_pos_dict['id': row['Chromosome']+'_'+str(row['Start_Position'])+'_'+row['Reference_Allele']+'_'+'D']= {'id': row['Chromosome']+'_'+str(row['Start_Position'])+'_'+row['Reference_Allele']+'_'+'D',
                                                                                'gene': row['Hugo_Symbol'],
                                                                                "missense": missense}
                
                mutation_list.append({'id': row['Chromosome']+'_'+str(row['Start_Position'])+'_'+row['Reference_Allele']+'_'+'D',
                                                                                'gene': row['Hugo_Symbol'],
                                                                                "missense": missense})
                
            elif row['Variant_Type'] == 'INS':
                chrom_pos_dict['id': row['Chromosome']+'_'+str(row['Start_Position'])+'_'+'I'+'_'+row['Tumor_Seq_Allele2']]= {'id': row['Chromosome']+'_'+str(row['Start_Position'])+'_'+row['Reference_Allele']+'_'+row['Tumor_Seq_Allele2'],
                                                                                'gene': row['Hugo_Symbol'],
                                                                                "missense": missense}
                
                mutation_list.append({'id': row['Chromosome']+'_'+str(row['Start_Position'])+'_'+'I'+'_'+row['Tumor_Seq_Allele2'],
                                                                                'gene': row['Hugo_Symbol'],
                                                                                "missense": missense})
                


        
    
    outer_dict = {'id': args.id,
                'sample_trees': []}


    trees = summ_data['trees']

    for tree in trees:
        
        inner_sample_tree_dict = {'topology': [], 
                                'score' : trees[tree]['llh']}
                
        print(tree)
        
        with open('./'+args.tree_directory+'/'+str(tree)+'.json', 'r') as f:
        # Load the JSON data into a dictionary
            treefile = json.load(f)

        bigtree = makeChild(tree)
        
        inner_sample_tree_dict['topology'] = bigtree

        outer_dict['sample_trees'].append(inner_sample_tree_dict)


    outer_dict['Mutations'] = mutation_list
    
    #TODO format HLA_gene input data, depending on format inputted.  They should look like this A*02:01
    #this will be setup for polysolver winners output
    def convert_polysolver_hla(polyHLA):
        allele=polyHLA[4]
        shortHLA = polyHLA.split('_')[2:4]
        return allele.upper() +'*'+ shortHLA[0] + ':' + shortHLA[1]
        
    HLA_gene_li = []
    with open(args.HLA_genes,'r') as f:
        for line in f:
            line = line.split('\t')
            
            HLA_gene_li.append(convert_polysolver_hla(line[1]))
            HLA_gene_li.append(convert_polysolver_hla(line[2]))
            
    outer_dict['HLA_genes'] = HLA_gene_li
    


    if args.optional_file:
        #TODO format optional input data, depending on format of inputted file.  I was imagining a tsv, but can be anything
        status = 0
        OS_tmp = 0
        PFS    = 0
        
        outer_dict['status'] = status
        outer_dict['OS']     = OS_tmp
        outer_dict['PFS']    = PFS
    else:
        outer_dict['status'] = 0
        outer_dict['OS']     = 0
        outer_dict['PFS']    = 0

    outer_dict['id']      = args.id
    outer_dict['patient'] = args.patient_id
    outer_dict['cohort']  = args.cohort
    

    outjson = args.patient_id +'_' + args.id +'_' +'.json'
    with open(outjson, 'w') as tstout:
        json.dump(outer_dict, tstout, indent=1)
        # tstout.write(json.dumps(outer_dict))
    


def parse_args():
    parser = argparse.ArgumentParser(description="Process input files and parameters")
    parser.add_argument("maf_file", help="Path to the MAF file")
    parser.add_argument("summary_file", help="Path to the summary file")
    parser.add_argument("mutation_file", help="Path to the mutation file")
    parser.add_argument("tree_directory", help="Path to the tree directory containing json files")
    parser.add_argument("id", help="ID")
    parser.add_argument("patient_id", help="Patient ID")
    parser.add_argument("cohort", help="Cohort")
    parser.add_argument("HLA_genes", help="Path to the file containing HLA genes")
    parser.add_argument("--patient_data_file", help="Path to the optional file containing status, overall survival, and PFS")
    parser.add_argument('-v', '--version', action='version', version='%(prog)s 1.0')

    return parser.parse_args()

def print_help():
    print("Usage: python eval_phyloWGS.py <maf_file> <summary_file> <mutation_file> <tree_directory> <id> <patient_id> <cohort> <HLA_genes> [--optional_file OPTIONAL_FILE]")
    print("Example: python eval_phyloWGS.py file.maf summary_file.txt mutation_file.txt ./tree_directory/ id patient_id cohort HLA_genes_file --optional_file optional_file.txt")
    print("Arguments:")
    print("  maf_file\t\tPath to the MAF file")
    print("  summary_file\t\tPath to the summary file from PhyloWGS")
    print("  mutation_file\t\tPath to the mutation file from PhyloWGS")
    print("  id\t\t\tID")
    print("  patient_id\t\tPatient ID")
    print("  cohort\t\tCohort")
    print("  HLA_genes\t\tPath to the file containing HLA genes")
    print("  --optional_file\t(Optional) Path to the optional file containing status, overall survival, and PFS")
    

if __name__ == "__main__":
    args = parse_args()
    print("MAF File:", args.maf_file)
    print("Summary File:", args.summary_file)
    print("Mutation File:", args.mutation_file)
    print("Tree directory:",args.tree_directory)
    print("ID:", args.id)
    print("Patient ID:", args.patient_id)
    print("Cohort:", args.cohort)
    print("HLA Genes File:", args.HLA_genes)
    if args.optional_file:
        print("Optional File:", args.optional_file)
        
    main(args)