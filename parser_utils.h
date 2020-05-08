#include <stdio.h>
#include <stdlib.h>

#include <vector>
#include <map>
#include <algorithm>
#include <cstring>

extern int yylineno;

enum Identifier_type
{
    undefined,
    function,
    parameter,
    variable
};


struct Identifier
{
    Identifier(Identifier_type t, void* pd,const char* n) : type(t), pData(pd), name(n) {}
    Identifier_type type = Identifier_type::undefined;
    void* pData;
    const char* name;
};



struct function_data
{
    function_data(const char* n = nullptr) : name(n){}
    const char* name;
    unsigned num_param = 0, num_var = 0;
};

//for char* comparison for the map keys
struct cmp_str
{
   bool operator()(char const *a, char const *b) const
   {
      return std::strcmp(a, b) < 0;
   }
};

class context
{
    std::vector<std::map<const char*, Identifier, cmp_str>> scopes;
    std::vector<function_data> func_list;
public:
    function_data* cur_fun; //current function

    context() = default;

    Identifier& define(const char* name, Identifier&& f) 
    {
        auto r = scopes.back().emplace(name, std::move(f));
        return r.first->second;
    }

    Identifier& def_var(const char* name) 
    {   //list_all();
        if(exists(name))
        {
            printf("Redefinition of %s on line %d \n", name, yylineno);
            exit(0);
        }
        printf("defined new variable %s \n", name);
        if(cur_fun != nullptr)
            cur_fun->num_var++;
            
        return define(name, Identifier(Identifier_type::variable, nullptr, name));
    }

    Identifier& def_param(const char* name) 
    {
        if(exists(name))
        {
            error("Identifier %s already exists \n", name);
            exit(0);
        } 
        printf("Defined new parameter %s \n", name);
        cur_fun->num_param++;
        return define(name, Identifier(Identifier_type::parameter, nullptr, name));
    }

    Identifier& def_func(const char* name)
    {
        if(exists(name))
        {
            printf("Identifier %s already exists \n", name);
            exit(0);
        }
        printf("Defined new function %s \n", name);
        return define(name, Identifier(Identifier_type::function, nullptr, name));
    }
    void add_func(const char* name) 
    { 
        func_list.emplace_back(name); 
        cur_fun = &(func_list.back());
    }

    /*Identifier& find_id(const char* name)
    {
        for(auto& scope : scopes)
        {
            if ( scope.find(name) == scope.end() ) {
                // not found
                return NULL;
            } else {
                return (scope[name]);
            }
        }
    }*/

    bool exists(const char* name)
    {
        for (auto i = scopes.rbegin(); i != scopes.rend(); ++i ) 
        { 
            if ( i->find(name) != i->end() )
            {
                return true;
            } 
        } 
        return false;
    }

    void can_use(const char* name)
    {
        if(exists(name))
            return;
        else
        {
            printf("%s is not declared in this scope. Line %d \n", name, yylineno);
            exit(0);
        }
        
    }

    void list_all()
    {
        printf("############################################### \n");
        for (auto i = scopes.rbegin(); i != scopes.rend(); ++i ) 
        { 
            for (auto j = i->rbegin(); j != i->rend(); ++j)
            {
                printf(j->first);
                printf(" \n");

            } 
        } 
        printf("############################################### \n");
    }

    void list_funcs()
    {
        for(auto& f : func_list)
        {
            printf("function %s has %d parameters and %d variables \n", f.name, f.num_param, f.num_var);
        } 
    }

    //operators
    void operator ++() { scopes.emplace_back();}
    void operator --() { scopes.pop_back();}
};

void warning(const char* msg)
{
    printf("\033[0;33m");
    printf("WARNING line %d: %s \n ",yylineno ,msg);
    printf("\033[0m");
}

void error(const char* msg)
{
    printf("\033[0;31m");
    printf("ERROR line %d: %s \n ",yylineno ,msg);

    printf("\n");
    printf("\033[0m");
}