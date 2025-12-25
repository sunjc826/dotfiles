function dotfiles_bu_pre_init_entrypoint()
{
    bu_preinit_register_user_defined_key_binding '\et' dotfiles_bind_tmux_on_off

    bu_preinit_register_user_defined_completion_func code dotfiles_autocomplete_completion_func_code
}

BU_USER_DEFINED_STATIC_PRE_INIT_ENTRYPOINT_CALLBACKS=(
    dotfiles_bu_pre_init_entrypoint
)
