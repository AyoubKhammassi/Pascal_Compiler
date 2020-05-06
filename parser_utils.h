#include <stdio.h>
#include <stdlib.h>

#include <vector>
#include <map>


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

class context
{
    std::vector<std::map<const char*, Identifier>> scopes;
    std::vector<function_data> func_list;
    function_data fun; //current function
public:
    context() = default;

    Identifier& define(const char* name, Identifier&& f) 
    {
        auto r = scopes.back().emplace(name, std::move(f));
        return r.first->second;
    }
    void def_param(){}

    Identifier& def_var(const char* name) { printf("defined new variable %s \n", name); return define(name, Identifier(Identifier_type::variable, nullptr, name));}
    Identifier& def_param(const char* name) { return define(name, Identifier(Identifier_type::parameter, nullptr, name));}
    Identifier& def_func(const char* name) { return define(name, Identifier(Identifier_type::function, nullptr, name));}
    void Add_func(char* name) { func_list.push_back(function_data(name)) ;}

    //operators
    void operator ++() { scopes.emplace_back();}
    void operator --() { scopes.pop_back();}


};