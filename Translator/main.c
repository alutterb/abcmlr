#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define DATASETS 1

int isNumber(char *line);
char *convertDirec(char *direc);

int main()
{
    /*********** READ CSV FILE***********/
    FILE *ifp;
    int parts = 0;
    int configs = 0;

    char *DIREC = malloc(sizeof(char)*2048);
    char *buffer = malloc(sizeof(char)*2048);

    printf("Enter file path: \n");
    fgets(buffer,2048,stdin);
    sscanf(buffer,"%s",DIREC);
    printf("Enter any character to continue: \n");
    getchar();

    char *nDIREC = convertDirec(DIREC);
    printf("Your Directory: %s\n",nDIREC);

    ifp = fopen(nDIREC,"r");

    if(ifp == NULL){
        fprintf(stderr,"Input file not read.\n");
        exit(1);
    }

    int rows = 0;
    int columns = 0;

    /* gets proper dimensions of array, excludes any text */
    char build[1024];
    while (fgets(build, 1024, ifp)){
        char read;
        const char *tok;
        int c = 0;

        for (tok = strtok(build, ","); tok && *tok; tok = strtok(NULL, ",\n")){
            if(isNumber(tok)==1){
                read = 'Y';
                c++;
            }
            else{
                read == 'N';
            }
        }
        if(read == 'Y'){
            rows++;
            columns = c;
        }
    }
    fseek(ifp,0,SEEK_SET);

    /*Get Number of Agents */
    char bufs[1024];
    int agents = 1;
    int nrows = 0;

    char* temp = malloc(sizeof(char)*48);

    while (fgets(bufs, 1024, ifp)){
        const char *tok = strtok(bufs,",");
        if(nrows>0){
            if(strcmp(temp,tok) != 0){
                ++agents;
            }
        }
        strcpy(temp,tok);
        nrows++;
    }
    if(nrows > rows)
        --agents;

    fseek(ifp,0,SEEK_SET);

    /* Get Stops in Array to Separate Agents */
    int stops[agents];
    for(int i = 0; i < agents; i++){
        stops[i]=0;
    }
    int sCount = 0;
    int cycle = 0;
    char bufss[1024];
    char *temp2 = malloc(sizeof(char)*48);


    while (fgets(bufss, 1024, ifp)){
        const char *tok = strtok(bufss,",");
        if(cycle>0){
            if(nrows>rows){
                if(cycle>1){
                    if(strcmp(temp2,tok)== 0){
                        ++stops[sCount];
                    }
                    if(strcmp(temp2,tok)!= 0){
                        if(sCount<agents)
                            ++sCount;
                    }
                }
            }
            else{
                if(strcmp(temp2,tok)== 0){
                        ++stops[sCount];
                        printf("%s ",tok);
                }
                if(strcmp(temp2,tok)!= 0){
                    printf("Next sequence\n");
                    if(sCount<agents)
                        ++sCount;
                }
            }
        }
        strcpy(temp2,tok);
        ++cycle;
    }

    fseek(ifp,0,SEEK_SET);
    /*assign parts and configs */
    parts = columns-1;
    configs = rows;

    /*builds array of integers */
    int arr[rows][columns];
    char buf[1024];
    int r = 0;

    while (fgets(buf,1024,ifp)) {
        char read;
        const char *tok;
        int ret =0;
        int c = 0;

        for (tok = strtok(buf, ","); tok && *tok; tok = strtok(NULL, ",\n")){
                if(isNumber(tok)==1){
                    read = 'Y';
                    ret = strtol(tok,NULL,10);
                    arr[r][c] = ret;
                    c++;
                }
                else{
                    read = 'N';
                }
        }
        if(read == 'Y')
            r++;
    }
    fseek(ifp,0,SEEK_SET);

    /*Process Names*/
    char names[columns-1][1024];
    const char *token;
    fgets(buf,1024,ifp);
    int iter = 0;

    for(token = strtok(buf,","); token && *token; token = strtok(NULL,",\n")){
        if(iter > 1){
            sscanf(token, "%s",names[iter-2]);
        }
        iter++;
    }
    fclose(ifp);

    /* sums of each parts */
    int counts[columns-1][1];

    for(int i = 1; i < columns; i++){
        int temp = 0;
        for(int j = 0; j < rows; j++){
            temp += arr[j][i];
        }
        counts[i-1][0] = temp;
    }

    /*Find max # of part for each part*/
    int maxPart[columns-1][1];

    for(int i = 1; i < columns; i++){
        int max = arr[0][i];
        for(int j = 0; j < rows; j++){
            if(arr[j][i]>max)
                max=arr[j][i];
        }
        maxPart[i-1][0] = max;
    }

    /***********BUILD CONFIG FILE***********/
    /* set starting points*/
    int starts[agents+1];
    for (int i = 0; i < agents+1; ++i)
        starts[i] = 0;
    for (int i = 1; i<agents+1;i++){
        starts[i] = stops[i-1]+1;
    }

    /* set up files */
    FILE *files[agents];
    for(int i = 0; i < agents; i++){
        char filename[20];
        sprintf(filename,"agent%d.cfg", i+1);
        files[i] = fopen(filename,"w");
    }

    int start = 0;
    int end = 0;

    for(int i = 0; i < agents; ++i){
        start += starts[i];
        end = (start+1+stops[i]);

        if(files[i] == NULL){
            fprintf(stderr,"Output file not created.\n");
            exit(1);
        }

        /*create parts section*/
        fprintf(files[i],"%d\n",parts);
        fprintf(files[i],"%d\n",stops[i]+1);

        /*create probability row*/
        for(int j = start; j<end; ++j)
            fprintf(files[i],"%d ", arr[j][0]);

        fprintf(files[i],"\n",NULL);

        /*do the rest*/
        for(int j = 1; j < columns; j++){
            fprintf(files[i], "%s ", names[j-1]);
            for(int k = start; k<end; ++k){
                fprintf(files[i],"%d ", arr[k][j]);
                if(k == end-1)
                    fprintf(files[i],"\n",NULL);
            }
        }
        fclose(files[i]);
    }

    /***********BUILD CNT FILE***********/
    FILE *f = fopen("spc.cnt","w");
    if(f == NULL){
        fprintf(stderr,"Output file not created.\n");
        exit(1);
    }

    /*Number of parts and datasets*/
    fprintf(f,"%d\n",parts);
    fprintf(f,"%d\n",DATASETS);

    /*Part names and sum of their respect parts*/
    for(int i = 0; i<columns-1; i++){
        fprintf(f,"%s    ", names[i]);
        fprintf(f,"%d\n", counts[i][0]);
    }
    fclose(f);

    /***********BUILD BDF FILE***********/
    f = fopen("bondef.bdf","w");
    if(f == NULL){
        fprintf(stderr,"Output file not created.\n");
        exit(1);
    }
    /*hardcoded densities*/
    float density[24] = {0.49,0.165,0.17,0.26,0.3,0.32,0.18,0.26,0.34,0.25,0.51,0.52,0.41,0.5,0.63,0.5,0.33,0.37,0.33,0.31,0.51,0.50,0.60,0.48};
    /*parts*/
    fprintf(f,"%d\n",parts);
    fprintf(f,"\n",NULL);

    /*Name, Max number found in configuration, density*/
    for(int i = 0; i < columns-1; i++){
        fprintf(f,"%s    ",names[i]);
        fprintf(f,"%d    ",maxPart[i][0]);
        fprintf(f,"%.3f\n",density[i]);
    }
}

int isNumber(char *line){
    int isDigit = 0;
    int j=0;
    while(j<strlen(line)){
        isDigit = isdigit(line[j]);
        if(isDigit == 0)
            break;
        j++;
    }
    return (isDigit);
}

char *convertDirec(char direc[]){
    for(int i = 0; i < strlen(direc); i++){
        if(direc[i]=='/'){
            direc[i]='\\';
        }
    }
    return direc;
}

