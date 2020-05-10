#include <stdio.h>
#include <stdlib.h>

#include <vector>
#include <map>
#include <algorithm>
#include <cstring>
#include <sstream>

#include "console.h"

enum Identifier_type
{
    undefined,
    function,
    parameter,
    variable
};

struct Identifier
{
    Identifier(Identifier_type t, void* pd,const char* n) : type(t), pData(pd), name(n), used(false) {}
    Identifier_type type = Identifier_type::undefined;
    void* pData;
    const char* name;
    bool used;
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
            error("Redefinition of %s \n", name);
            return *(find_id(name));
            //exit(0);
        }
        printf("Defined new variable %s \n", name);
        if(cur_fun != nullptr)
            cur_fun->num_var++;
            
        return define(name, Identifier(Identifier_type::variable, nullptr, name));
    }

    Identifier& def_param(const char* name) 
    {
        if(exists(name))
        {
            error("Redefinition of %s \n", name);
            return *(find_id(name));
            //exit(0);
        } 
        printf("Defined new parameter %s \n", name);
        cur_fun->num_param++;
        return define(name, Identifier(Identifier_type::parameter, nullptr, name));
    }

    Identifier& def_func(const char* name)
    {
        if(exists(name))
        {
            error("Redefinition of %s \n", name);
            return *(find_id(name));
            //exit(0);
        }
        printf("Defined new function %s \n", name);
        return define(name, Identifier(Identifier_type::function, nullptr, name));
    }
    void add_func(const char* name) 
    { 
        func_list.emplace_back(name); 
        cur_fun = &(func_list.back());
    }

    Identifier* find_id(const char* name)
    {
        for (auto i = scopes.rbegin(); i != scopes.rend(); ++i ) 
        { 
            auto v = i->find(name);
            if ( v != i->end() )
            {
                return &(v->second);
            } 
        }
        return nullptr;
    }

    bool exists(const char* name)
    {
        return (find_id(name)!=nullptr);
    }

    void can_use(const char* name)
    {
        Identifier* id = find_id(name);
        if(id!=nullptr && !id->used)
        {
            //Mark this identifier as used
            id->used = true;
        }
        else
        {
            error("%s is not declared in this scope \n", name);
            //exit(0);
        }
        
    }


    void list_funcs()
    {
        printf("############################################### \n");
        printf("List of defined functions: \n");
        for(auto& f : func_list)
        {
            printf("function %s has %d parameters and %d variables \n", f.name, f.num_param, f.num_var);
        } 
    }

    //operators
    void operator ++() { scopes.emplace_back();}
    void operator --() 
    {
        for(auto& id : scopes.back())
        {
            if(id.second.type != Identifier_type::function && !id.second.used)
                warning("%s is declared but never used \n", id.first);
        }
        scopes.pop_back();
    }
};

