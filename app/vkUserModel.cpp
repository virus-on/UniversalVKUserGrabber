#include "vkUserModel.h"

namespace App
{

VkUserModel::VkUserModel(QObject *parent)
    : QAbstractListModel(parent)
    , sortType_(SortType::ByName)
    , cityNameFilter_("")
    , genderFilter_(-1)
{}

void VkUserModel::setFilters(int gender, const SortType &sortBy, const QString &cityName)
{
    genderFilter_   = gender;
    sortType_       = sortBy;
    cityNameFilter_ = cityName;
}

void VkUserModel::setUsers(const std::list<User> &users)
{
    allUsers_ = users;
}

void VkUserModel::addUsersToModel()
{
    resetModel();

    if (sortType_ == SortType::ByName)
    {
        allUsers_.sort([](const auto& rhs, const auto& lhs){
            return rhs.fullName < lhs.fullName;
        });
    }
    else if (sortType_ == SortType::ByCity)
    {
        allUsers_.sort([](const auto& rhs, const auto& lhs){
            return rhs.cityName < lhs.cityName;
        });
    }
    else
    {
        allUsers_.sort([](const auto& rhs, const auto& lhs){
            return rhs.id < lhs.id;
        });
    }


    for (const auto& user: allUsers_)
    {
        if (genderFilter_ != -1 && user.sex != genderFilter_)
            continue;
        if (!cityNameFilter_.isEmpty() && (!user.cityName.contains(cityNameFilter_) && !user.homeTown.contains(cityNameFilter_)))
            continue;
        beginInsertRows(QModelIndex(), rowCount(), rowCount());
        modelData_.push_back(user);
        endInsertRows();
    }

    /// ToDo: insert users to model
}

void VkUserModel::resetModel()
{
    removeRows(0, modelData_.count(), QModelIndex());
}

QHash<int, QByteArray> VkUserModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[IdRole]       = "IdRole";
    roles[NameRole]     = "NameRole";
    roles[SexRole]      = "SexRole";
    roles[CityRole]     = "CityRole";
    roles[HomeTownRole] = "HomeTownRole";

    return roles;
}

int VkUserModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return modelData_.count();
}

QVariant VkUserModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= modelData_.count())
        return QVariant();

    const User &user = modelData_[index.row()];
    if (role == IdRole)
        return QVariant(user.id);
    else if (role == NameRole)
        return user.fullName;
    else if (role == SexRole)
        return user.sex;
    else if (role == CityRole)
        return user.cityName;
    else if (role == HomeTownRole)
        return user.homeTown;
    return QVariant();
}

bool VkUserModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (row < 0 || row >= modelData_.count() || count == 0 || row + count > modelData_.count())
        return false;

    beginRemoveRows(parent, row, row + count);
    for (int i = 0; i < count; i++)
        modelData_.removeAt(row);
    endRemoveRows();
    return true;
}

} // App
