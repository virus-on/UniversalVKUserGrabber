#ifndef VKUSERMODEL_H
#define VKUSERMODEL_H

#include <QAbstractListModel>


namespace App
{

struct User
{
    QString fullName;
    int     id = 0;
    int     sex = 2;  // male by default
    QString cityName;
    QString homeTown;
};

enum SortType {
    ByName = 0,
    ByCity = 1,
    ById = 2
};

class VkUserModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum UserRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        SexRole,
        CityRole,
        HomeTownRole
    };

    VkUserModel(QObject *parent = nullptr);
    void setFilters(int gender = -1, const SortType& sortBy = SortType::ByName, const QStringList& cityNames = {});
    void setUsers(const std::list<User>& users);
    void addUsersToModel();
    void resetModel();

    int         rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant    data(const QModelIndex & index, int role = Qt::DisplayRole) const;
    bool        removeRows(int row, int count, const QModelIndex &parent = QModelIndex());

protected:
    QHash<int, QByteArray> roleNames() const;


protected:
    std::list<User>allUsers_;
    QList<User>     modelData_;
    SortType        sortType_;
    QStringList     cityNameFilter_;
    int             genderFilter_;
};

} // App

#endif // VKUSERMODEL_H
