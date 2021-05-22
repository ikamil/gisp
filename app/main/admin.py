from django.contrib import admin
from django.utils import timezone
from datetime import datetime
from .models import *
from django.utils.safestring import mark_safe
from django.db.models import Q
from django.urls import resolve
from admin_auto_filters.filters import AutocompleteFilter
from django.contrib.admin import SimpleListFilter


class BranchFilter(SimpleListFilter):
    title = 'Отрасль' # or use _('country') for translated title
    parameter_name = 'appliance_id'

    def lookups(self, request, model_admin):
        return [(x.id, x.name) for x in Branch.objects.all()]

    def queryset(self, request, queryset):
        if self.value():
            return queryset.filter(appliance_id__contains=Branch.objects.get(pk=self.value()).name)


def fnow():
    return timezone.make_aware(datetime.now(),timezone.get_default_timezone()).astimezone(timezone.get_default_timezone())


class RegionFilter(AutocompleteFilter):
    title = 'Регион' # display title
    field_name = 'region' # name of the foreign key field


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


class DictAdmin(BaseAdmin):
    list_display = ['name']
    fields = ['name', 'modified']
    search_fields = ['name']


class ImageBaseAdmin(BaseAdmin):
    def img(self, obj):
        return mark_safe("""<img width="100px" src="%s">""" % ((str(obj.image) if str(obj.image).startswith('http') else obj.image.url) if obj.image else ''))

    list_display = ['name', 'description', 'image']
    fields = ['name', 'description', 'image', 'img']
    readonly_fields = ['img', 'modifier', 'deleted']


admin.site.enable_nav_sidebar = False


@admin.register(Region)
class RegionAdmin(DictAdmin):
    search_fields = ['name']


@admin.register(Dict)
class DictAdmin(DictAdmin):
    pass


@admin.register(Branch)
class BranchAdmin(DictAdmin):
    pass


@admin.register(OKPD)
class OKPDAdmin(DictAdmin):
    pass


@admin.register(Support)
class SupportAdmin(BaseAdmin):
    fields = ['url', 'small_name', 'okved1_rate', 'okved2_rate', 'okved3_rate', 'total_rate',
          'full_name', 'number_npa', 'date_npa', 'npa_name', 'description', 'purpose',
          'objective', 'type_mera', 'type_format_support', 'srok_vozvrata', 'procent_vozvrata', 'guarante_periode',
          'guarantee_cost', 'appliance_id', 'okved2', 'complexity', 'amount_of_support', 'regularity_select', 'period',
          'dogovor', 'gos_program', 'event', 'dop_info', 'is_not_active', 'prichina_not_act', 'req_zayavitel',
          'request_project', 'is_sofinance', 'dolya_isofinance', 'budget_project', 'pokazatel_result',
          'territorial_level', 'region', 'respons_structure', 'org_id']
    list_display = ['small_name', 'region', 'appliance_id', 'okved1_rate', 'okved2_rate', 'okved3_rate', 'total_rate']
    search_fields = ['small_name', 'full_name', 'region__name']
    list_filter = [BranchFilter, 'region']
    ordering = ['-total_rate']

    class Media:
        pass


@admin.register(NonFinanceSup)
class NonFinanceSupAdmin(BaseAdmin):
    fields = ['company', 'name', 'dict', 'okpd2']
    list_display = ['company', 'name', 'dict', 'okpd2']
    search_fields = ['name', 'company__name']
    raw_id_fields = ['company', 'dict', 'okpd2']


@admin.register(BranchStat)
class BranchStatAdmin(BaseAdmin):
    fields = ['region', 'branch', 'okpd2', 'rate']
    list_display = ['region', 'branch', 'okpd2', 'rate']
    search_fields = ['region__name', 'branch__name', 'okpd2__name']
    raw_id_fields = ['okpd2']


@admin.register(Company)
class CompanyAdmin(BaseAdmin):
    fields = ['full_name', 'email', 'platforms', 'okved2', 'enterprise_type', 'main_activity', 'additional_activity',
          'legal_form', 'company_type', 'company_status', 'reg_date', 'tax_code', 'real_address', 'attributes', 'name',
          'organization_type', 'industry', 'ogrn', 'inn', 'checkpoint', 'region', 'address', 'contact_email',
          'website', 'contact_number']
    list_display = ['name', 'region', 'company_status', 'real_address']
    search_fields = ['name', 'full_name', 'email', 'region__name']
    list_filter = [RegionFilter]

