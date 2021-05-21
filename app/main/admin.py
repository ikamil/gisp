from django.contrib import admin
from django.utils import timezone
from datetime import datetime
from .models import *
from django.utils.safestring import mark_safe
from django.db.models import Q
from django.urls import resolve
from admin_auto_filters.filters import AutocompleteFilter


def fnow():
    return timezone.make_aware(datetime.now(),timezone.get_default_timezone()).astimezone(timezone.get_default_timezone())


class BaseAdmin(admin.ModelAdmin):
    list_display = ['name', 'description']
    fields = ['name', 'description', 'modified']
    save_as = True
    readonly_fields = ['creator', 'created', 'modifier', 'modified', 'deleted', 'deleter']

    def get_queryset(self, request):
        qs = super(BaseAdmin, self).get_queryset(request)
        if request.user.is_superuser:
            return qs.filter(deleted__isnull=True)
        else:
            return qs.filter(Q(deleted__isnull=True) & Q(creator=request.user))

    def formfield_for_foreignkey(self, db_field, request, **kwargs):
        # if db_field.name == "brand":
        #     if request.user.is_superuser:
        #         kwargs["queryset"] = Brands.objects.filter(deleted__isnull=True)
        #     else:
        #         kwargs["queryset"] = Brands.objects.filter(Q(deleted__isnull=True) & Q(pk__in=BrandUser.objects.filter(Q(user=request.user) & Q(deleted__isnull=True)).values('brand')))
        return super().formfield_for_foreignkey(db_field, request, **kwargs)

    def delete_model(self, request, obj):
        obj.deleter = request.user
        obj.deleted = fnow()
        obj.save()

    def delete_queryset(self, request, queryset):
        for dl in queryset:
            self.delete_model(request, dl)

    def save_model(self, request, obj, form, change):
        obj.creator = request.user if not getattr(obj, 'creator') else getattr(obj, 'creator')
        obj.created = fnow() if not getattr(obj, 'created') else getattr(obj, 'created')
        if hasattr(obj, 'modifier'):
            obj.modifier = request.user
        if hasattr(obj, 'changer'):
            obj.changer = request.user
        return super(BaseAdmin, self).save_model(request, obj, form, change)

    # def save_related(self, request, form, formsets, change):
        # raise Exception([dict(form) for form in formsets])
        # return super(BaseInline, self.save_related(request, form, formsets, change))

    def has_delete_permission(self, request, obj=None):
        if '/change/' in request.__str__() and request.__str__() != getattr(request, '_editing_document', False):  # query attribute
            return False
        return super(BaseAdmin, self).has_delete_permission(request, obj=obj)

    def has_change_permission(self, request, obj=None):
        if '/change/' in request.__str__() and type(self) != getattr(request, '_editing_document', False):  # query attribute
            return False
        return super(BaseAdmin, self).has_change_permission(request, obj=obj)

    def _changeform_view(self, request, object_id=None, form_url='', extra_context=None):
        request._editing_document = type(self)
        return super(BaseAdmin, self)._changeform_view(request, object_id=object_id, form_url=form_url, extra_context=extra_context)


class ImageBaseAdmin(BaseAdmin):
    def img(self, obj):
        return mark_safe("""<img width="100px" src="%s">""" % ((str(obj.image) if str(obj.image).startswith('http') else obj.image.url) if obj.image else ''))

    list_display = ['name', 'description', 'image']
    fields = ['name', 'description', 'image', 'img']
    readonly_fields = ['img', 'modifier', 'deleted']


admin.site.enable_nav_sidebar = False


@admin.register(Region)
class RegionAdmin(ImageBaseAdmin):
    pass


@admin.register(Support)
class SupportAdmin(ImageBaseAdmin):
    fields = ['url', 'small_name', 'full_name', 'number_npa', 'date_npa', 'npa_name', 'description', 'purpose',
          'objective', 'type_mera', 'type_format_support', 'srok_vozvrata', 'procent_vozvrata', 'guarante_periode',
          'guarantee_cost', 'appliance_id', 'okved2', 'complexity', 'amount_of_support', 'regularity_select', 'period',
          'dogovor', 'gos_program', 'event', 'dop_info', 'is_not_active', 'prichina_not_act', 'req_zayavitel',
          'request_project', 'is_sofinance', 'dolya_isofinance', 'budget_project', 'pokazatel_result',
          'territorial_level', 'region', 'respons_structure', 'org_id']
    list_display = ['small_name', 'region', 'description', 'procent_vozvrata', 'amount_of_support', 'event']
